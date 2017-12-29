import Vapor
import FluentProvider
import HTTP

//Slack Structure
//token=cm6zhoAdx6REx0jqA0agfqQQ
//team_id=T0001
//team_domain=example
//channel_id=C2147483705
//channel_name=test
//timestamp=1355517523.000005
//user_id=U2147483697
//user_name=Steve
//text=googlebot: What is the air-speed velocity of an unladen swallow?
//trigger_word=googlebot:


final class Post: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var userID: String
    var userName: String
    var text: String
    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let userID = "user_id"
        static let userName = "user_name"
        static let text = "text"
    }

    /// Creates a new Post
    init(userID: String, userName: String, text: String) {
        self.userID = userID
        self.userName = userName
        self.text = text
    }

    // MARK: Fluent Serialization

    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        userID = try row.get(Post.Keys.userID)
        userName = try row.get(Post.Keys.userName)
        text = try row.get(Post.Keys.text)
    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.Keys.userID, userID)
        try row.set(Post.Keys.userName, userName)
        try row.set(Post.Keys.text, text)
        return row
    }
}

// MARK: Fluent Preparation

extension Post: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Post.Keys.userID)
            builder.string(Post.Keys.userName)
            builder.string(Post.Keys.text)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Post: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            userID: try json.get(Post.Keys.userID),
            userName: try json.get(Post.Keys.userName),
            text: try json.get(Post.Keys.text)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Post.Keys.id, id)
        try json.set(Post.Keys.userID, userID)
        try json.set(Post.Keys.userName, userName)
        try json.set(Post.Keys.text, text)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Post: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Post: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Post>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Post.Keys.text, String.self) { post, text in
                post.text = text
            },
            
            UpdateableKey(Post.Keys.userName, String.self) { post, userName in
                post.userName = userName
            },
            
            UpdateableKey(Post.Keys.userID, String.self) { post, userID in
                post.userID = userID
            }
        ]
    }
}
