import Quick
import Nimble
import Squeal

class SelectHelpersSpec: QuickSpec {
    override func spec() {
        var database : Database!
        
        beforeEach {
            database = Database.newTemporaryDatabase()
            
            try! database.execute("CREATE TABLE contacts (contactId INTEGER PRIMARY KEY, name TEXT, initials TEXT)")
            try! database.insertInto("contacts", values:["name": "Amelia", "initials": "A"])
            try! database.insertInto("contacts", values:["name": "Brian",  "initials": NSNull()])
            try! database.insertInto("contacts", values:["name": "Cara",   "initials": "C"])
        }
        
        afterEach {
            database = nil
        }
        
        // -----------------------------------------------------------------------------------------
        // MARK: Select
        
        describe("Database.selectFrom(_:columns:whereExpr:groupBy:having:orderBy:limit:offset:parameters:)") {
            
            var values : [String]?
            
            afterEach { values = nil }
            
            context("when the statement is valid") {
                
                beforeEach {
                    values = try! database.selectFrom("contacts") { $0["name"] as! String }
                }
                
                it("returns the collected values") {
                    expect(values?[0]).to(equal("Amelia"))
                    expect(values?[1]).to(equal("Brian"))
                    expect(values?[2]).to(equal("Cara"))
                }
                
            }

            
            context("when the statement has a where clause") {
                
                beforeEach {
                    values = try! database.selectFrom("contacts",
                                                      whereExpr:  "contactId > ?",
                                                      orderBy:    "name",
                                                      parameters: [1]) { $0["name"] as! String }
                }
                
                it("returns the collected values") {
                    expect(values?[0]).to(equal("Brian"))
                    expect(values?[1]).to(equal("Cara"))
                }
                
            }

            context("when the statement has a limit and offset") {
                
                beforeEach {
                    values = try! database.selectFrom("contacts",
                                                      whereExpr:  "contactId > ?",
                                                      orderBy:    "name",
                                                      limit:      1,
                                                      offset:     1,
                                                      parameters: [1]) { $0["name"] as! String }
                }
                
                it("returns the collected values") {
                    expect(values?[0]).to(equal("Cara"))
                    expect(values?.count).to(equal(1))
                }
                
            }
            
            context("when the statement is invalid") {
                
                beforeEach {
                    
                }
                
                it("provides an error") {
                    do {
                        _ = try database.prepareSelectFrom("contacts", whereExpr: "sdfsdfsf IS NULL")
                        fail("Expected error")
                    } catch {
                        
                    }
                }
                
            }
            
        }
        
        // -----------------------------------------------------------------------------------------
        // MARK: Query
        
        describe("Statement.queryIds()") {
            
            var rowIds : [RowId]?
            
            beforeEach {
                rowIds = try! database.selectIdsFrom("contacts",
                                                     whereExpr:   "name > ?",
                                                     orderBy:     "name DESC",
                                                     parameters:  ["B"])
            }
            
            afterEach {
                rowIds = nil
            }
            
            it("returns the IDs of the selected rows") {
                expect(rowIds).to(equal([3, 2]))
            }
            
        }
        
        // -----------------------------------------------------------------------------------------
        // MARK: Count

        describe("Database.countFrom(_:columns:whereExpr:parameters:)") {
            
            var count : Int64?
            
            context("when no whereExpr is provided") {
                beforeEach {
                    count = try! database.countFrom("contacts")
                }
                
                it("counts all rows") {
                    expect(count).to(equal(3))
                }
            }
            
            context("when columns are provided") {
                beforeEach {
                    count = try! database.countFrom("contacts", columns:["initials"])
                }
                
                it("counts all rows with non-null values") {
                    expect(count).to(equal(2))
                }
            }
            
            context("when a where clause is provided") {
                beforeEach {
                    count = try! database.countFrom("contacts", whereExpr:"contactId > ?", parameters:[2])
                }
                
                it("counts all rows matching the expression") {
                    expect(count).to(equal(1))
                }
            }
            
        }
        
    }
}
