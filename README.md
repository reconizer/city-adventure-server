# CityAdventure

## Description

CityAdventure is a software application designed to help users explore cities in a fun and interactive way.
This is a server-side application that will be used in conjunction with clients:

- [iOS](https://github.com/reconizer/city-adventure-ios)
- [Android](https://github.com/reconizer/city-adventure-android)
- [Web](https://github.com/reconizer/city-adventure-web)

## Installation

1. Clone the repository: `git clone https://github.com/yourusername/CityAdventure.git`
2. Navigate into the project directory: `cd CityAdventure`
3. Install the dependencies: `mix deps.get`
4. Create and migrate the database: `mix ecto.setup`

## Usage

To start the application, run the following command in your terminal:

```bash
iex -S mix sever
```

## Deployment

There is a simple deployment script that can be used to deploy the application to the AWS.
To deploy the application, run the following command in your terminal:

```bash
SERVER_PATH=<uri to the server instance> KEY_PATH=<path to the ssh key file for accessing the server> ./deploy.sh
```
