import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {}

    // MARK: - Setup
    func setupDatabase() {
        let path = dbPath()
        if sqlite3_open(path, &db) == SQLITE_OK {
            createTables()
            print("✅ Database opened at: \(path)")
        } else {
            print("❌ Failed to open database")
        }
    }

    private func dbPath() -> String {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("foodorder.sqlite").path
    }

    private func createTables() {
        let sql = """
            CREATE TABLE IF NOT EXISTS user (
                id TEXT PRIMARY KEY NOT NULL,
                login TEXT NOT NULL UNIQUE,
                pass TEXT NOT NULL,
                adress TEXT NOT NULL
            );
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - User CRUD
    func createUser(login: String, pass: String, adress: String) -> User? {
        // Check if login exists
        if userExists(login: login) { return nil }

        let id = UUID().uuidString
        let sql = "INSERT INTO user (id, login, pass, adress) VALUES (?, ?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (login as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (pass as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (adress as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                sqlite3_finalize(stmt)
                return User(id: id, login: login, pass: pass, adress: adress)
            }
        }
        sqlite3_finalize(stmt)
        return nil
    }

    func loginUser(login: String, pass: String) -> User? {
        let sql = "SELECT id, login, pass, adress FROM user WHERE login = ? AND pass = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (login as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (pass as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_ROW {
                let id     = String(cString: sqlite3_column_text(stmt, 0))
                let uLogin = String(cString: sqlite3_column_text(stmt, 1))
                let uPass  = String(cString: sqlite3_column_text(stmt, 2))
                let uAddr  = String(cString: sqlite3_column_text(stmt, 3))
                sqlite3_finalize(stmt)
                return User(id: id, login: uLogin, pass: uPass, adress: uAddr)
            }
        }
        sqlite3_finalize(stmt)
        return nil
    }

    func userExists(login: String) -> Bool {
        let sql = "SELECT COUNT(*) FROM user WHERE login = ?;"
        var stmt: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (login as NSString).utf8String, -1, nil)
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)
        return count > 0
    }

    func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
            db = nil
        }
    }
}
