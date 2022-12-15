//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
// import “hardhat/console.sol”;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OnTheChainBank is Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    enum Levels {
        UNREGISTERED,
        ACCT_OPENED,
        BONUS_CLAIMED,
        LOAN_APPROVED
    }
    struct LoanApplication {
        uint256 amount;
        uint256 blockNumber;
    }
    // Events
    event AccountCreation(address indexed account);
    // Holds bank account address and bitmap for completed levels
    mapping(address => uint8) public addresses;
    // Holds bank account balances
    mapping(address => uint256) private balances;
    // Holds account creation dates
    mapping(address => uint256) public creationTimes;
    // Holds credit scores for bank accounts
    mapping(address => uint256) public creditScores;
    // Holds time of last credit check
    mapping(address => uint256) public lastCreditCheck;
    mapping(address => LoanApplication) public loanApplications;

    constructor(address _admin) {
        // Set up bank administrator
        _setupRole(ADMIN_ROLE, _admin);
    }

    function checkAccountTier() external view returns (uint8) {
        return addresses[msg.sender];
    }

    function getAccountCreationTime() external view returns (uint256) {
        return creationTimes[msg.sender];
    }

    function updateAccount(address _address, uint256 _newTimestamp)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(creationTimes[_address] != 0, "Account does not exist");
        creationTimes[_address] = _newTimestamp;
    }

    function create() external {
        // Ensure user hasn't already registered
        require(addresses[msg.sender] == 0, "User already registered!");
        addresses[msg.sender] = uint8(Levels.ACCT_OPENED);
        creationTimes[msg.sender] = block.timestamp;
        creditScores[msg.sender] = 740;
        lastCreditCheck[msg.sender] = block.timestamp;
        emit AccountCreation(msg.sender);
    }

    function deposit() external payable {
        require(addresses[msg.sender] != 0, "Please open an account first");
        require(msg.value > 0, "Please deposit a nonzero amount");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(
            _amount != 0 && _amount <= balances[msg.sender],
            "Not enough funds in account"
        );
        balances[msg.sender] -= _amount;
        (bool sent, ) = msg.sender.call{value: _amount}("");
    }

    function checkBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function requestCreditCheck(address _address) external returns (uint256) {
        require(addresses[_address] != 0, "Account does not exist!");
        uint256 creditScore = 850;
        creditScores[_address] = creditScore;
        lastCreditCheck[_address] = block.number;
        return creditScore;
    }

    function applyForLoan(address _address, uint256 _amount) external {
        LoanApplication memory loanApp = LoanApplication(_amount, block.number);
        loanApplications[_address] = loanApp;
    }

    function approveLoan(address _address) external {
        require(
            loanApplications[_address].amount != 0,
            "User does not have pending loan"
        );
        require(creditScores[_address] > 740, "Credit score too low");
        require(
            lastCreditCheck[_address] == block.number,
            "Need recent credit check"
        );
        require(
            loanApplications[_address].blockNumber == block.number,
            "Loan application expired"
        );
        addresses[_address] = addresses[_address] | uint8(Levels.LOAN_APPROVED);
    }

    function getBonus() external {
        uint256 waitPeriod = 3 days;
        require(
            block.timestamp >= creationTimes[msg.sender] + waitPeriod,
            "Please wait 72 hours"
        );
        require(
            addresses[msg.sender] & uint8(Levels.BONUS_CLAIMED) == 0,
            "Bonus already claimed"
        );
        addresses[msg.sender] =
            addresses[msg.sender] |
            uint8(Levels.BONUS_CLAIMED);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function destroy() external {
        selfdestruct(payable(owner()));
    }

    receive() external payable {}

    fallback() external payable {}
}
