# Unsplsh.

## Demo
![App Video](./Unsplsh_Demo.gif)

## Description
A simple project demonstrating API requests to the Unsplash API using a UITableView to display the images with custom ImageCell that subclasses UITableViewCell. The API request is made with URLSession and the response is handled with the JSONDecoder and decoded into their respective objects (as structs) using the Codable protocol. From here the urls to the images are extracted for each cell and an Operation object is created with the sole purpose to download the data at the specific url. These operations are placed into an array, acting as a queue/list to track what photo is still in progress. Once the download is complete the Operation's completion block is called and the specific table view row is reloaded and the oepration is removed from the queue.

Credit to https://www.raywenderlich.com/5293-operation-and-operationqueue-tutorial-in-swift as the basis for the project which was adapted for the Unsplash API - https://unsplash.com


