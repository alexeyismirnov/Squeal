import Foundation

public extension Database {
    
    public func prepareInsertInto(_ tableName:String, columns:[String]) throws -> Statement {
        var sqlFragments = ["INSERT INTO"]
        sqlFragments.append(escapeIdentifier(tableName))
        sqlFragments.append("(")
        sqlFragments.append(columns.map { escapeIdentifier($0) }.joined(separator: ", "))
        sqlFragments.append(")")
        sqlFragments.append("VALUES")
        sqlFragments.append("(")
        sqlFragments.append(columns.map { _ in "?" }.joined(separator: ","))
        sqlFragments.append(")")
        
        return try prepareStatement(sqlFragments.joined(separator: " "))
    }
    
    /// Inserts a table row. This is a helper for executing an INSERT INTO statement.
    ///
    /// :param: tableName   The name of the table to insert into.
    /// :param: columns     The column names of the values to insert.
    /// :param: values      The values to insert. The values in this array must be in the same order as the respective
    ///                     `columns`.
    ///
    /// :returns:   The id of the inserted row. sqlite assigns each row a 64-bit ID, even if the primary key is not an
    ///             INTEGER value.
    ///
    @discardableResult
    public func insertInto(_ tableName:String, columns:[String], values:[Bindable?]) throws -> Int64 {
        let statement = try prepareInsertInto(tableName, columns:columns)
        try statement.bind(values)
        try statement.execute()
        
        return lastInsertedRowId
    }

    /// Inserts a table row. This is a helper for executing an INSERT INTO statement.
    ///
    /// :param: tableName   The name of the table to insert into.
    /// :param: values      The values to insert, keyed by the column name.
    ///
    /// :returns:   The id of the inserted row. sqlite assigns each row a 64-bit ID, even if the primary key is not an
    ///             INTEGER value.
    ///
    @discardableResult
    public func insertInto(_ tableName:String, values valuesDictionary:[String:Bindable?]) throws -> Int64 {
        var columns = [String]()
        var values = [Bindable?]()
        for (columnName, value) in valuesDictionary {
            columns.append(columnName)
            values.append(value)
        }
        
        return try insertInto(tableName, columns:columns, values:values)
    }
    
}
