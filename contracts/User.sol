// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract User{
    struct UserData
     {
        address userAddress;
        string username;
        uint256 balance
        bool isLoggedIn
    }

    mapping (address => UserData) private users;

    event UserRegistered(address indexed userAddress, string userName);
    event UserLoggedIn(address indexed userAddress);
    event UserLoggedOut(address indexed userAddress);
  

function registerUser(string memory _username) public {
    // check if user is  already registered
    require(users[msg.sender].userAddress == address(0), "User already registered" );

    users[msg.sender] = UserData(msg.sender,  _username,0);

    emit UserRegistered(msg.sender, _username)
    
}

  function getUser(address _userAddress) public view returns (UserData memory) {
        return users[_userAddress];
    }

function login()  public   {
    require(!users[msg.sender].isLoggedIn, "User already logged in" );
    users[msg.sender].isLoggedIn = true;
    emit UserLoggedIn(msg.sender)
}

function logout() public  {
    require(users[msg.sender].isLoggedIn, "User already logged out");
    users[msg.sender].isLoggedIn = false;
    emit UserLoggedOut(msg.sender)
}

 function isLoggedIn(address _userAddress) public view returns (bool) {
        return users[_userAddress].isLoggedIn;
    }


}