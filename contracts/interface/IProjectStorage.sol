pragma solidity 0.6.6;
import "./IProjectSchema.sol";
pragma experimental ABIEncoderV2;

interface IProjectStorage is IProjectSchema {

    function CreateContributorRecordMapping(
        address projectId,
        uint256 amountContributed,
        address payable contributor
    ) external;

    function UpdateProjectRecordMapping(uint256 amount, address projectAddress, uint contributorId)
        external;

   function CreateProject(
        string calldata name,
        string calldata description,
        uint256 _durationInSeconds,
        string calldata projectUrl,
        uint256 goal,
         address payable creator,
         uint256 deadline,
         uint256 dateCreated
    ) external returns (address projectId);

  function getProjectsRecordById(address ProjectRecordId)
        external
        view
        returns ( 
        address projectId,
        address payable projectCreator,
        string memory projectTitle,
        string memory projectDescription,
        uint256 deadlineInSeconds,
        uint256 durationInSeconds,
        string memory projectUrl,
        uint256 totalAmountContributed,
        uint256 numberOfContributors,
        uint256 goal,
        ContributorRecord[] memory contributors);

    function getAllProjects() external view returns (ProjectRecord[] memory);

    function GetProjectRecordIndexFromProjectCreator(address creator)
        external
        view
        returns (uint256);

    function GetProjectRecordIdFromProjectRecordIndexAndProjectCreatorRecord(
        uint256 recordIndex,
        address projectCreator
    ) external view returns (address);

    function GetContributorRecordIndexFromContributor(address contributor)
        external
        view
        returns (uint256);

    function GetContributorRecordIdFromContributorRecordIndexAndContributor(
        uint256 recordIndex,
        address contributor
    ) external view returns (uint);

   function GetContributorRecordById(uint contributorId)
        external
        view
        returns ( bool exist,
        address projectId,
        address funder,
        uint _funderId,
        uint256 amountContributed);
    function UpdateContributionRecordMapping (uint256 amount, address projectAddress, uint contributorId) external;
        
    function CreateSpendingRequestMapping (string calldata description, uint256 amount, address payable spendingRequestRecipient, address projectAddress) external returns (uint);
    
    function UpdateSpendingRequest (uint _spendingRequestId, uint _numberOfVoters, bool isCompleted, address projectAddress) external;
    
   function GetRequestById(uint _spendingRequestId) external view returns (   uint256 spendingRequestId,
        string memory description,
        uint256 value,
        bool exist,
        address payable recipient,
        bool isCompleted,
        uint256 numberOfVoters);
    
    function GetRequestId() external view returns (uint);
    
    
    
}

