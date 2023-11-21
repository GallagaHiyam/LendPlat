// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedLendingPlatform is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public collateralToken;
    IERC20 public loanToken;

    uint256 public loanDuration;
    uint256 public interestRate; // Annual interest rate in percentage (e.g., 5 for 5%)

    struct Loan {
        address borrower;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        bool repaid;
    }

    mapping(address => Loan) public loans;

    event LoanInitiated(address indexed borrower, uint256 amount, uint256 endTime);
    event LoanRepaid(address indexed borrower, uint256 amount);

    modifier onlyNotBorrower() {
        require(loans[msg.sender].borrower == address(0), "Borrower cannot initiate another loan");
        _;
    }

    constructor(
        address _collateralToken,
        address _loanToken,
        uint256 _loanDuration,
        uint256 _interestRate
    ) {
        require(_collateralToken != address(0), "Invalid collateral token address");
        require(_loanToken != address(0), "Invalid loan token address");
        require(_loanDuration > 0, "Loan duration must be greater than 0");

        collateralToken = IERC20(_collateralToken);
        loanToken = IERC20(_loanToken);
        loanDuration = _loanDuration;
        interestRate = _interestRate;
    }
function initiateLoan(uint256 _loanAmount) external onlyNotBorrower {
        require(_loanAmount > 0, "Loan amount must be greater than 0");

        // Transfer collateral from the borrower to the contract
        collateralToken.safeTransferFrom(msg.sender, address(this), _loanAmount);

        uint256 interestAmount = (_loanAmount * interestRate * loanDuration) / (365 * 100); // Simple interest calculation

        loans[msg.sender] = Loan({
            borrower: msg.sender,
            amount: _loanAmount,
            startTime: block.timestamp,
            endTime: block.timestamp + loanDuration,
            repaid: false
        });

        // Mint loan tokens to the borrower
        loanToken.safeTransfer(msg.sender, _loanAmount - interestAmount);

        emit LoanInitiated(msg.sender, _loanAmount, loans[msg.sender].endTime);
    }
function repayLoan() external {
        Loan storage loan = loans[msg.sender];
        require(loan.borrower == msg.sender, "No active loan for the borrower");
        require(!loan.repaid, "Loan already repaid");
        require(block.timestamp <= loan.endTime, "Loan has expired");

        uint256 interestAmount = (loan.amount * interestRate * (block.timestamp - loan.startTime)) / (365 * 100);
        uint256 totalRepayment = loan.amount + interestAmount;

        // Transfer loan tokens from the borrower to the contract
        loanToken.safeTransferFrom(msg.sender, address(this), totalRepayment);

        // Transfer collateral back to the borrower
        collateralToken.safeTransfer(msg.sender, loan.amount);

        loan.repaid = true;

        emit LoanRepaid(msg.sender, totalRepayment);
    }
function getLoanDetails(address _borrower) external view returns (uint256, uint256, uint256, bool) {
        Loan storage loan = loans[_borrower];
        return (loan.amount, loan.startTime, loan.endTime, loan.repaid);
    }

}
