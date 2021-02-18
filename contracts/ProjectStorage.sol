pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./helpers/SafeMath.sol";
import "./Project.sol";
import "./interface/IProjectSchema.sol";
import "./helpers/StorageOwners.sol";

contract ProjectStorage is IProjectSchema, StorageOwners {
    using SafeMath for uint256;

    //list of projects
    ProjectRecord[] private ProjectRecords;

    //list of Project contributors
    ContributorRecord[] private Contributors;
    
    uint SpendingRequestId;
    
    uint ContributorsId;
    
    mapping(uint => SpendingRequest) SpendingRequestMapping;

    mapping(uint => ContributorRecord) private ContibutorsRecordMapping; //mapping contributors address to contributor record

    mapping(address => uint256) private ContibutorsRecordtoProjectIndexMapping; // tracks the number of projects contributed to by index

    mapping(address => mapping(uint => uint))
        private ContributorsToContributorsRecordIndexToContributorsIDMapping; // this maps the contributor to the contributor record index and then to the contributor record id

    mapping(address => ProjectRecord) private projectRecordMapping; // mapping a project address to project record

    mapping(address => uint256) private ProjectCreatorToProjectIndexMapping; //  This tracks the number of projects by index created by an address

    mapping(address => mapping(uint256 => address)) private ProjectCreatorToProjectIndexToProjectIDMapping; //  This maps the project creator to the project index and then to the project ID
    

    
    function CreateSpendingRequestMapping (string calldata description, uint256 amount, address payable spendingRequestRecipient, address projectAddress) onlyStorageOracle  external returns (uint) {
        
        SpendingRequestId = SpendingRequestId.add(1);
        
        SpendingRequest storage spendingRequest = SpendingRequestMapping[SpendingRequestId];
        
        spendingRequest.recipient = spendingRequestRecipient;
        
        spendingRequest.exist = true;
        
        spendingRequest.isCompleted = false;
        
        spendingRequest.numberOfVoters = 0;
        
        spendingRequest.spendingRequestId = SpendingRequestId;
        
        spendingRequest.description = description;
        
        spendingRequest.value = amount;
        
        ProjectRecord storage projects = projectRecordMapping[projectAddress];
        
        projects.request.push(spendingRequest);
        
         
        
        return SpendingRequestId;
        
    }
    
    function UpdateSpendingRequest (uint _spendingRequestId, uint _numberOfVoters, bool isCompleted, address projectAddress) onlyStorageOracle external {
        SpendingRequest storage spendingRequest = SpendingRequestMapping[_spendingRequestId];
        
        spendingRequest.spendingRequestId = _spendingRequestId;
        
        spendingRequest.numberOfVoters = _numberOfVoters;
        
        spendingRequest.isCompleted = isCompleted;
        
         ProjectRecord storage projects = projectRecordMapping[projectAddress];
        
        projects.request.push(spendingRequest);
        
        
    }
    
    
    function GetRequestById(uint _spendingRequestId) external view returns (   uint256 spendingRequestId,
        string memory description,
        uint256 value,
        bool exist,
        address payable recipient,
        bool isCompleted,
        uint256 numberOfVoters) {
        SpendingRequest memory requests = SpendingRequestMapping[_spendingRequestId];
        
        return (requests.spendingRequestId, requests.description, requests.value, requests.exist, requests.recipient, requests.isCompleted, requests.numberOfVoters);
    }
      function _GetRequestById(uint _spendingRequestId) internal view returns (SpendingRequest memory) {
        SpendingRequest memory requests = SpendingRequestMapping[_spendingRequestId];
        
        return requests;
    }
    
    function GetRequestId() external view returns (uint) {
        
        return SpendingRequestId;
    }
    
    function _GetRequestId() internal view returns (uint) {
        return SpendingRequestId;
    }
    
    

    function _CreateContibutorToContibutorRecordIndexToContributorRecordIDMapping(
        address payable contributor,
        uint contributorRecordId
    ) onlyStorageOracle internal {
        ContibutorsRecordtoProjectIndexMapping[
            contributor
        ] = ContibutorsRecordtoProjectIndexMapping[contributor].add(1);

        uint256 ContributorProjectRecordIndex =
            ContibutorsRecordtoProjectIndexMapping[contributor];

        mapping(uint => uint) storage contributorRecordIndex =
            ContributorsToContributorsRecordIndexToContributorsIDMapping[
                contributor
            ];

        contributorRecordIndex[
            ContributorProjectRecordIndex
        ] = contributorRecordId;
    }

    function _CreateProjectCreatorToProjectRecordIndexToProjectIDMapping(
        address payable projectCreator,
        address projectId
    ) onlyStorageOracle internal {
        ProjectCreatorToProjectIndexMapping[
            projectCreator
        ] = ProjectCreatorToProjectIndexMapping[projectCreator].add(1);

        uint256 ProjectCreatedRecordIndex =
            ProjectCreatorToProjectIndexMapping[projectCreator];

        mapping(uint256 => address) storage projectCreatedRecordIndex =
            ProjectCreatorToProjectIndexToProjectIDMapping[projectCreator];

        projectCreatedRecordIndex[ProjectCreatedRecordIndex] = projectId;
    }

    function _CreateProjectRecordMapping(
        string memory name,
        string memory description,
        uint256 _durationInSeconds,
        string memory projectUrl,
        uint256 goal,
        uint256 deadline,
        address projectAddress,
        address payable creator
    ) onlyStorageOracle internal {
        
        ProjectRecord storage projects = projectRecordMapping[projectAddress];
        
        projects.projectCreator = creator;

        projects.projectId = projectAddress;

        projects.projectTitle = name;

        projects.projectDescription = description;

        projects.deadlineInSeconds = deadline;

        projects.durationInSeconds = _durationInSeconds;

        projects.projectUrl = projectUrl;

        projects.totalAmountContributed = 0;

        projects.numberOfContributors = 0;

        projects.goal = goal;

        ProjectRecords.push(projects);
    }

    function CreateContributorRecordMapping(
        address projectId,
        uint256 amountContributed,
        address payable contributor
    ) onlyStorageOracle external {
        
         ContributorsId = ContributorsId.add(1);
        

        ContributorRecord storage contributors =
            ContibutorsRecordMapping[ContributorsId];

        contributors.exist = true;
        
        contributors.funder = contributor;

        contributors._funderId = ContributorsId;

        contributors.amountContributed = amountContributed;

        contributors.projectId = projectId;

        _CreateContibutorToContibutorRecordIndexToContributorRecordIDMapping(contributor, ContributorsId);
        
         ProjectRecord storage projects = projectRecordMapping[projectId];

        projects.totalAmountContributed = projects.totalAmountContributed.add(
            amountContributed
        );

        projects.numberOfContributors = projects.numberOfContributors.add(1);
    
     projects.contributors.push(contributors);

        Contributors.push(contributors);
    }
    
    function UpdateContributionRecordMapping (uint256 amount, address projectAddress, uint256 contributorId)
      onlyStorageOracle  external
    {
        
         ProjectRecord storage projects = projectRecordMapping[projectAddress];

    
        ContributorRecord storage contributorsRecord = ContibutorsRecordMapping[contributorId];
        
        contributorsRecord.amountContributed = amount;
        
      
        projects.contributors.push(contributorsRecord);

       
        
    }

    function UpdateProjectRecordMapping( address projectAddress)
      onlyStorageOracle  external
    {

        ProjectRecord storage projects = projectRecordMapping[projectAddress];

        // uint256 currentRequestId = _GetRequestId();
        
        // SpendingRequest memory spendingRequest = _GetRequestById(currentRequestId);
        
        // if(spendingRequest.exist == true) {
        //     projects.request.push(spendingRequest);
        // }
        

        ProjectRecords.push(projects);
    }

    function GetProjectRecordIndexFromProjectCreator(address creator)
        external
        view
        returns (uint256)
    {
        return ProjectCreatorToProjectIndexMapping[creator];
    }

    function GetProjectRecordIdFromProjectRecordIndexAndProjectCreatorRecord(
        uint256 recordIndex,
        address projectCreator
    ) external view returns (address) {

            mapping(uint256 => address)
                storage projectCreatedRecordIndextoRecordId
         = ProjectCreatorToProjectIndexToProjectIDMapping[projectCreator];

        return projectCreatedRecordIndextoRecordId[recordIndex];
    }

    function GetContributorRecordIndexFromContributor(address contributor)
        external
        view
        returns (uint256)
    {
        return ContibutorsRecordtoProjectIndexMapping[contributor];
    }

    function GetContributorRecordIdFromContributorRecordIndexAndContributor(
        uint256 recordIndex,
        address contributor
    ) external view returns (uint) {
        mapping(uint => uint) storage contributorRecordIndextoRecordId =
            ContributorsToContributorsRecordIndexToContributorsIDMapping[
                contributor
            ];

        return contributorRecordIndextoRecordId[recordIndex];
    }

    function GetContributorRecordById(uint contributorId)
        external
        view
        returns ( bool exist,
        address projectId,
        address funder,
        uint _funderId,
        uint256 amountContributed)
    {
        ContributorRecord memory contributors =
            ContibutorsRecordMapping[contributorId];

        return (contributors.exist, contributors.projectId, contributors.funder, contributors._funderId, contributors.amountContributed);
    }

    //This function creates a new project
    function CreateProject(
        string calldata name,
        string calldata description,
        uint256 _durationInSeconds,
        string calldata projectUrl,
        uint256 goal,
         address payable creator,
         uint256 deadline,
         uint256 dateCreated
    ) onlyStorageOracle external returns (address projectId)  {


        Project newProject =
            new Project(
                name,
                description,
                deadline,
                _durationInSeconds,
                projectUrl,
                goal,
                dateCreated
            );

        address projectAddress = address(newProject);

        _CreateProjectRecordMapping(
            name,
            description,
            _durationInSeconds,
            projectUrl,
            goal,
            deadline,
            projectAddress,
            creator
        );

        _CreateProjectCreatorToProjectRecordIndexToProjectIDMapping(
            creator,
            projectAddress
        );

        return projectAddress;
    }

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
        ContributorRecord[] memory contributors)
    {
      
        ProjectRecord memory projects = projectRecordMapping[ProjectRecordId];

        return ( projects.projectId, projects.projectCreator, projects.projectTitle, projects.projectDescription, projects.deadlineInSeconds, projects.durationInSeconds, projects. projectUrl,
        projects.totalAmountContributed, projects.numberOfContributors, projects.goal, projects.contributors);
    }

    function getAllProjects() external view returns (ProjectRecord[] memory) {
        return ProjectRecords;
    }
    
     
}
