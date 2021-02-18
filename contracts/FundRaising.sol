pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "./helpers/SafeMath.sol";
import "./interface/IProjectStorage.sol";
import "./interface/IProjectSchema.sol";
import "./interface/IERC20.sol";

contract FundRaisingContainers is IProjectSchema {
    //State public state = State.Fundraising; // initialize on create

    using SafeMath for uint256;

    IERC20 busdToken = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

    IProjectStorage projectStorage;

    // Event that will be emitted whenever funding will be received
    event FundingReceived(address payable contributor, uint256 amount);

    // Event that will be emitted whenever the project starter has received the funds
    event CreatorPaid(address recipient);

    //Create spending request event

    // event SpendingRequestEvent (address recipient, uint256 requestId, uint256 amount);

    //create vote spending request event

    event VoteSpendingRequest(address voter);

    //project created event

    event CreatedProject(
        address projectId,
        string projectTitle,
        string projectDescription,
        uint256 deadlineInSeconds,
        uint256 durationInSeconds,
        string projectUrl,
        uint256 goal
    );

    mapping(address => bool) voters;

    function updateStorageContract(address _projectStorageContractAddress)
        public
    {
        projectStorage = IProjectStorage(_projectStorageContractAddress);
    }

    function _getProjectRecordById(address ProjectId)
        internal
        view
        returns (ProjectRecord memory)
    {
        (
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
        ContributorRecord[] memory contributors
        ) = projectStorage.getProjectsRecordById(ProjectId);

        return
            ProjectRecord(
                ProjectId,
                projectCreator,
                projectTitle,
                projectDescription,
                deadlineInSeconds,
                durationInSeconds,
                projectUrl,
                totalAmountContributed,
                numberOfContributors,
                goal,
                contributors
            );
    }

    function _getContributorsRecordById(uint256 contributorId)
        internal
        view
        returns (ContributorRecord memory)
    {
        (
            bool exist,
            address projectId,
            address funder,
            uint256 _funderId,
            uint256 amountContributed
        ) = projectStorage.GetContributorRecordById(contributorId);

        return
            ContributorRecord(
                true,
                projectId,
                funder,
                _funderId,
                amountContributed
            );
    }

    // function _getRequestRecordById(uint256 _requestId) internal view returns (SpendingRequest memory){
    //     (  uint256 spendingRequestId,
    //     string memory description,
    //     uint256 value,
    //     bool exist,
    //     address payable recipient,
    //     bool isCompleted,
    //     uint256 numberOfVoters) = projectStorage.GetRequestById(_requestId);

    //     return SpendingRequest(spendingRequestId, description, value, true, recipient, isCompleted, numberOfVoters);
    //}

    /** @dev Function to payout for a spending request
  

       /** @dev Function to get balance .
     */
    function getProjectBalance(address projectAddress)
        public
        view
        returns (uint256)
    {
        return busdToken.balanceOf(projectAddress);
    }

    /** @dev Function to retrieve donated amount when a project expires and when a goal is not met.
     */
    function getRefund(address projectAddress, uint256 contributorId) public {
        address contributor = msg.sender;

        ProjectRecord memory projectRecords =
            _getProjectRecordById(projectAddress);

        uint256 deadline = projectRecords.deadlineInSeconds;

        uint256 raisedAmount = projectRecords.totalAmountContributed;

        require(
            block.timestamp > deadline,
            "Fund Raising is still in progress"
        );

        require(
            raisedAmount < projectRecords.goal,
            "Contribution amount is not less that the goal"
        );

        ContributorRecord memory contributorsRecord =
            _getContributorsRecordById(contributorId);

        uint256 amountContibuted = contributorsRecord.amountContributed;

        require(
            amountContibuted > 0,
            "amount contributed must be greater than 0"
        );

        busdToken.transferFrom(projectAddress, contributor, amountContibuted);

        projectStorage.UpdateContributionRecordMapping(
            0,
            projectAddress,
            contributorId
        );
    }

    /** @dev Function to vote for a spending request
     */
    // function voteForSpendingRequest(uint256 requestId, address projectId, uint contributorId) public {

    //     address payable contributor = msg.sender;

    //     bool isCompleted;

    //     SpendingRequest memory requests = _getRequestRecordById(requestId);

    //     _checkContributorExistandAmoutContributed(contributorId, contributor);

    //     voters[contributor] = true;

    //     uint256 votes = requests.numberOfVoters.add(1);

    //     ProjectRecord memory projectRecords = _getProjectRecordById(projectId);

    //     if(projectRecords.numberOfContributors == requests.numberOfVoters){
    //         isCompleted = true;
    //     }else{
    //         isCompleted = false;
    //     }

    //     projectStorage.UpdateSpendingRequest(requestId, votes, isCompleted, projectId);

    // }
    function _checkContributorExistandAmoutContributed(
        uint256 contributorId,
        address payable contributor
    ) internal {
        ContributorRecord memory contributorsRecord =
            _getContributorsRecordById(contributorId);

        uint256 amountContibuted = contributorsRecord.amountContributed;

        require(
            contributorsRecord.exist == true,
            "Contributors record does not exist"
        );

        require(
            amountContibuted > 0,
            "amount contributed must be greater than 0"
        );

        require(
            voters[contributor] == false,
            "Contributor has already voted for this spending request"
        );
    }
}

contract FundRaising is FundRaisingContainers {
    constructor(address _projectStorageContractAddress) public {
        projectStorage = IProjectStorage(_projectStorageContractAddress);
    }

    /** @dev Function to create a project.
     */

    function CreateProject(
        string calldata name,
        string calldata description,
        uint256 _durationInSeconds,
        string calldata projectUrl,
        uint256 goal
    ) external returns (address) {
        address payable creator = msg.sender;

        uint256 deadline = block.timestamp.add(_durationInSeconds);

        address projectAddress =
            projectStorage.CreateProject(
                name,
                description,
                _durationInSeconds,
                projectUrl,
                goal,
                creator,
                deadline,
                block.timestamp
            );

        emit CreatedProject(
            projectAddress,
            name,
            description,
            deadline,
            _durationInSeconds,
            projectUrl,
            goal
        );

        return projectAddress;
    }

    /** @dev Function to fund a certain project.
     */
    function ContributeToProject(address projectId) external payable {
        address payable contributor = msg.sender;

        address recipient = address(this);

        ProjectRecord memory projectRecords = _getProjectRecordById(projectId);

        require(
            block.timestamp < projectRecords.deadlineInSeconds,
            "Deadline has reached, Project no longer raising funds"
        );

        uint256 amountTransferrable =
            busdToken.allowance(contributor, recipient);

        require(
            amountTransferrable > 0,
            "Approve an amount > 0 for token before proceeding"
        );

        busdToken.transferFrom(
            contributor,
            projectRecords.projectId,
            amountTransferrable
        );

        projectStorage.CreateContributorRecordMapping(
            projectRecords.projectId,
            amountTransferrable,
            contributor
        );

        emit FundingReceived(contributor, amountTransferrable);
    }

    /** @dev Function to create a spending request by project creator
     */
    // function createSpendingRequest(
    //     string memory _description,
    //     address payable _recipient,
    //     uint256 _value,
    //     address projectId
    // ) public returns(uint) {

    //     ProjectRecord memory projectRecords = _getProjectRecordById(projectId);

    //      uint256 raisedAmount = projectRecords.totalAmountContributed;

    //     _validateProjectCreator(projectId, _recipient);

    //     _validateProjectGoalReached(raisedAmount, projectRecords.goal);

    //    uint256 requestId = projectStorage.CreateSpendingRequestMapping(_description, _value, _recipient, projectId);

    //   return requestId;

    // }

    function payOut(address projectId) public {
        address payable sender = msg.sender;

        ProjectRecord memory projectRecords = _getProjectRecordById(projectId);

        address payable projectCreator = projectRecords.projectCreator;

        require(
            sender == projectCreator,
            "recipient must be the project creator"
        );

        //SpendingRequest memory requests = _getRequestRecordById(requestId);

        require(
            projectRecords.totalAmountContributed >= projectRecords.goal,
            "Goal has not been reached yet"
        );
        //require(requests.numberOfVoters > projectRecords.numberOfContributors.div(2), "Number of voters less than 50 %"); //more than 50% voted

        //uint SpendingRequestAmount = requests.value;

        uint256 contributionAmount = projectRecords.totalAmountContributed;

        busdToken.transferFrom(projectId, projectCreator, contributionAmount);

        bool isCompleted = true;

        // projectStorage.UpdateSpendingRequest(requestId, requests.numberOfVoters, isCompleted, projectId);

        emit CreatorPaid(projectCreator);
    }

    //check if the function caller is the project creator

    function _validateProjectCreator(address projectId) internal view {
        address payable sender = msg.sender;

        ProjectRecord memory projectRecords = _getProjectRecordById(projectId);

        address payable projectCreator = projectRecords.projectCreator;

        require(
            sender == projectCreator,
            "recipient must be the project creator"
        );
    }

    function _validateProjectGoalReached(uint256 raisedAmount, uint256 goal)
        internal
        pure
    {
        require(
            raisedAmount >= goal,
            "Raised amount must be equal to or greater than goal"
        );
    }
}
