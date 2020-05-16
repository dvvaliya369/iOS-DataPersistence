import Foundation
import SQLite3

struct SparkSQLite {
    static func openDatabase() -> OpaquePointer? {
        let dbURL = try! FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("spark.sqlite")
        
        var db: OpaquePointer? = nil
        if sqlite3_open(dbURL.path, &db) == SQLITE_OK {
            return db
        } else {
            print("Unable to open database.")
        }
        
        return db
    }
    
    static func initializeDataModel(connection: OpaquePointer) {
        let createEmployeesTableQuery =
        """
        CREATE TABLE IF NOT EXISTS Employees (
            EmployeeID INTEGER PRIMARY KEY,
            FirstName TEXT,
            LastName TEXT,
            Department TEXT
        );
        """
        
        let createInnovationIdeasTableQuery =
        """
        CREATE TABLE IF NOT EXISTS InnovationIdeas (
            InnovationIdeaID INTEGER PRIMARY KEY,
            Title TEXT,
            IdeaDescription TEXT NULL,
            IsDraft BOOLEAN,
            DateSubmitted TEXT NULL,
            SubmittedBy TEXT NULL,
            SubmitterEmailAddress TEXT NULL,
            SubmitterDepartment TEXT NULL,
            PartnerEmployeeID INTEGER NULL,
            CreationDate TEXT,
                FOREIGN KEY (PartnerEmployeeID) REFERENCES Employees(EmployeeID)
            
        );
        """
        
        var preparedQuery: OpaquePointer? = nil
        let result = sqlite3_prepare_v2(connection, createEmployeesTableQuery, -1, &preparedQuery, nil)
        if result == SQLITE_OK {
            sqlite3_step(preparedQuery)
        } else {
            print("CREATE TABLE SQL command could not be prepared.")
        }
        
        sqlite3_finalize(preparedQuery)
        
        preparedQuery = nil
        if sqlite3_prepare_v2(connection, createInnovationIdeasTableQuery, -1, &preparedQuery, nil) == SQLITE_OK {
            sqlite3_step(preparedQuery)
        } else {
            print("CREATE TABLE SQL command could not be prepared.")
        }
        
        sqlite3_finalize(preparedQuery)
    }
    
    //MARK: Create
    static func preloadEmployeesTable(connection: OpaquePointer) {
        let existingEmployeesIndicatorQuery = "SELECT EmployeeID FROM Employees LIMIT 1;"
        var preparedExistingEmployeesIndicatorQuery: OpaquePointer? = nil
        var existingID: Int32? = nil
        
        if sqlite3_prepare_v2(connection, existingEmployeesIndicatorQuery, -1, &preparedExistingEmployeesIndicatorQuery, nil) == SQLITE_OK {
            if (sqlite3_step(preparedExistingEmployeesIndicatorQuery) == SQLITE_ROW) {
                existingID = sqlite3_column_int(preparedExistingEmployeesIndicatorQuery, 0)
            }
        }
        
        sqlite3_finalize(preparedExistingEmployeesIndicatorQuery)
        
        guard existingID == nil else { return }
        
        let insertStatement =
        """
        INSERT INTO Employees
            SELECT NULL, 'Jane', 'Sherman', 'Accounting' UNION ALL
            SELECT NULL, 'Luke', 'Jones', 'Accounting' UNION ALL
            SELECT NULL, 'Kathy', 'Smith', 'Information Technology' UNION ALL
            SELECT NULL, 'Jerome', 'Rodriguez', 'Information Technology' UNION ALL
            SELECT NULL, 'Maria', 'Tillman', 'Legal' UNION ALL
            SELECT NULL, 'Paul', 'Stevens', 'Legal';
        """
        
        var preparedInsertStatement: OpaquePointer? = nil
        sqlite3_prepare_v2(connection, insertStatement, -1, &preparedInsertStatement, nil)
        sqlite3_step(preparedInsertStatement)
        sqlite3_finalize(preparedInsertStatement)
    }
    
    static func insertInnovationIdea(connection: OpaquePointer, innovationIdea: InnovationIdea) {
        let insertStatement =
        """
        INSERT INTO InnovationIdeas (Title, IdeaDescription, IsDraft, DateSubmitted, SubmittedBy, SubmitterEmailAddress, SubmitterDepartment, PartnerEmployeeID, CreationDate)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var preparedInsertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(connection, insertStatement, -1, &preparedInsertStatement, nil) == SQLITE_OK {
            let title = innovationIdea.title as NSString
            let ideaDescription = innovationIdea.ideaDescription as NSString
            let isDraft = innovationIdea.isDraft == true ? 1 : 0
            
            let dateSubmittedFormatter = DateFormatter()
            dateSubmittedFormatter.dateFormat = "yyyy-MM-dd"
            let dateSubmitted = dateSubmittedFormatter.string(from: innovationIdea.dateSubmitted) as NSString
            
            let submittedBy = (innovationIdea.submittedBy ?? "") as NSString
            let submitterEmailAddress = (innovationIdea.submitterEmailAddress ?? "") as NSString
            let submitterDepartment = (innovationIdea.submitterDepartment ?? "") as NSString
            
            let creationDateFormatter = DateFormatter()
            creationDateFormatter.dateFormat = "yyyy-MM-dd"
            let creationDate = creationDateFormatter.string(from: innovationIdea.creationDate) as NSString
            
            sqlite3_bind_text(preparedInsertStatement, 1, title.utf8String, -1, nil)
            sqlite3_bind_text(preparedInsertStatement, 2, ideaDescription.utf8String, -1, nil)
            sqlite3_bind_int(preparedInsertStatement, 3, Int32(isDraft))
            sqlite3_bind_text(preparedInsertStatement, 4, dateSubmitted.utf8String, -1, nil)
            sqlite3_bind_text(preparedInsertStatement, 5, submittedBy.utf8String, -1, nil)
            sqlite3_bind_text(preparedInsertStatement, 6, submitterEmailAddress.utf8String, -1, nil)
            sqlite3_bind_text(preparedInsertStatement, 7, submitterDepartment.utf8String, -1, nil)
            sqlite3_bind_int(preparedInsertStatement, 8, Int32(innovationIdea.partnerEmployeeID))
            sqlite3_bind_text(preparedInsertStatement, 9, creationDate.utf8String, -1, nil)
            
            if sqlite3_step(preparedInsertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        
        sqlite3_finalize(preparedInsertStatement)
    }
    
    //MARK: Read
    static func getAllEmployees(connection: OpaquePointer) -> [Employee] {
        var employees = [Employee]()
        
        let query = "SELECT * FROM Employees ORDER BY LastName, FirstName;"
        
        var preparedQuery: OpaquePointer? = nil
        if sqlite3_prepare_v2(connection, query, -1, &preparedQuery, nil) == SQLITE_OK {
            
            while (sqlite3_step(preparedQuery) == SQLITE_ROW) {
                let employeeId = sqlite3_column_int(preparedQuery, 0)
                
                let queryResultCol1 = sqlite3_column_text(preparedQuery, 1)
                let firstName = String(cString: queryResultCol1!)
                
                let queryResultCol2 = sqlite3_column_text(preparedQuery, 2)
                let lastName = String(cString: queryResultCol2!)
                
                let queryResultCol3 = sqlite3_column_text(preparedQuery, 3)
                let department = String(cString: queryResultCol3!)
                
                let employee = Employee(employeeID: Int(employeeId), firstName: firstName, lastName: lastName, department: department)
                employees.append(employee)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(preparedQuery)
        
        return employees
    }
    
    static func getAllInnovationIdeas(connection: OpaquePointer) -> [InnovationIdea] {
        var innovationIdeas = [InnovationIdea]()
        
        let query = "SELECT * FROM InnovationIdeas WHERE Date(CreationDate) > Date('Now', '-1 day') ORDER BY Title;"
        
        var preparedQuery: OpaquePointer? = nil
        if sqlite3_prepare_v2(connection, query, -1, &preparedQuery, nil) == SQLITE_OK {
            
            while (sqlite3_step(preparedQuery) == SQLITE_ROW) {
                let innovationIdeaID = sqlite3_column_int(preparedQuery, 0)
                
                let queryResultCol1 = sqlite3_column_text(preparedQuery, 1)
                let title = String(cString: queryResultCol1!)
                
                let queryResultCol2 = sqlite3_column_text(preparedQuery, 2)
                let ideaDescription = String(cString: queryResultCol2!)
                
                let isDraft = (sqlite3_column_int(preparedQuery, 3)) == 1 ? true : false
                
                let queryResultCol4 = sqlite3_column_text(preparedQuery, 4)
                let dateSubmittedString = String(cString: queryResultCol4!)
                
                let dateSubmittedFormatter = DateFormatter()
                dateSubmittedFormatter.dateFormat = "yyyy-MM-dd"
                let dateSubmitted = dateSubmittedFormatter.date(from: dateSubmittedString)!
                
                let queryResultCol5 = sqlite3_column_text(preparedQuery, 5)
                let submittedBy = String(cString: queryResultCol5!)
                
                let queryResultCol6 = sqlite3_column_text(preparedQuery, 6)
                let submitterEmailAddress = String(cString: queryResultCol6!)
                
                let queryResultCol7 = sqlite3_column_text(preparedQuery, 7)
                let submitterDepartment = String(cString: queryResultCol7!)
                
                let partnerEmployeeID = sqlite3_column_int(preparedQuery, 8)
                
                let creationDateFormatter = DateFormatter()
                creationDateFormatter.dateFormat = "yyyy-MM-dd"
                let creationDate = creationDateFormatter.date(from: dateSubmittedString)!
                
                let innovationIdea = InnovationIdea(innovationIdeaID: Int(innovationIdeaID),
                                                    title: title,
                                                    ideaDescription: ideaDescription,
                                                    isDraft: isDraft,
                                                    dateSubmitted: dateSubmitted,
                                                    submittedBy: submittedBy,
                                                    submitterEmailAddress: submitterEmailAddress,
                                                    submitterDepartment: submitterDepartment,
                                                    partnerEmployeeID: Int(partnerEmployeeID),
                                                    creationDate: creationDate)
                
                innovationIdeas.append(innovationIdea)
            }
            
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(preparedQuery)
        
        return innovationIdeas
    }
    
    //MARK: Update
    static func updateInnovationIdea(connection: OpaquePointer, innovationIdea: InnovationIdea) {
        let isDraft = innovationIdea.isDraft == true ? 1 : 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateSubmitted = dateFormatter.string(from: innovationIdea.dateSubmitted) as NSString
        
        let updateStatement =
        """
        UPDATE InnovationIdeas SET
            Title = '\(innovationIdea.title)',
            IdeaDescription = '\(innovationIdea.ideaDescription)',
            IsDraft = \(isDraft),
            DateSubmitted = '\(dateSubmitted)',
            SubmittedBy = '\(innovationIdea.submittedBy ?? "")',
            SubmitterEmailAddress = '\(innovationIdea.submitterEmailAddress ?? "")',
            SubmitterDepartment = '\(innovationIdea.submitterDepartment ?? "")',
            PartnerEmployeeID = \(innovationIdea.partnerEmployeeID)
        WHERE
            InnovationIdeaID = \(innovationIdea.innovationIdeaID!)
        """
        
        var preparedUpdateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(connection, updateStatement, -1, &preparedUpdateStatement, nil) == SQLITE_OK {
            sqlite3_step(preparedUpdateStatement)
        } else {
            print("UPDATE statement could not be prepared.")
        }
        
        sqlite3_finalize(preparedUpdateStatement)
    }
    
    //MARK: Delete
    static func deleteInnovationIdea(connection: OpaquePointer, innovationIdea: InnovationIdea) {
        let deleteStatement = "DELETE FROM InnovationIdeas WHERE InnovationIdeaID = \(innovationIdea.innovationIdeaID!)"
        
        var preparedDeleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(connection, deleteStatement, -1, &preparedDeleteStatement, nil) == SQLITE_OK {
            sqlite3_step(preparedDeleteStatement)
        } else {
            print("DELETE statement could not be prepared.")
        }
        
        sqlite3_finalize(preparedDeleteStatement)
    }
}
