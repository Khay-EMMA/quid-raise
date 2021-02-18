pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./helpers/SafeMath.sol";
import "./interface/IProjectSchema.sol";

contract Project {
    using SafeMath for uint256;
    
    uint goal;
    
    uint deadline;
    
    string projectName;
    
    string projectDescription;
    
    uint durationInSeconds;
    
    address projectOwner;

    string projectUrl;
    
    uint dateCreatedInSeconds;
 
   constructor(
        string memory name,
        string memory description,
        uint _deadline,
        uint256 _durationInSeconds,
        string memory _projectUrl,
        uint256 _goal,
        uint256 _dateCreated
    ) public {
        projectName = name;
        projectDescription = description;
        deadline = _deadline;
        durationInSeconds = _durationInSeconds;
        projectUrl = _projectUrl;
        goal = _goal;
        projectOwner = msg.sender;
        dateCreatedInSeconds = _dateCreated;
    }
    

}
