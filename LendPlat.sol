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


}
