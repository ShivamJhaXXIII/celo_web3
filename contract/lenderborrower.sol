// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LoanAgreement
 * @dev A simple smart contract to record borrower-lender relationships immutably.
 * The lender funds the contract, and the borrower can later repay the loan.
 */
contract LoanAgreement {
    address public lender;
    address public borrower;
    uint256 public loanAmount;
    bool public loanFunded;
    bool public loanRepaid;

    event LoanFunded(address indexed lender, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);

    /**
     * @dev Set up the borrower and the loan amount when deploying.
     * @param _borrower The address of the borrower
     * @param _loanAmount The amount (in wei) agreed upon
     */
    constructor(address _borrower, uint256 _loanAmount) {
        lender = msg.sender;
        borrower = _borrower;
        loanAmount = _loanAmount;
    }

    /**
     * @dev The lender sends Ether to fund the loan.
     */
    function fundLoan() external payable {
        require(msg.sender == lender, "Only lender can fund");
        require(!loanFunded, "Loan already funded");
        require(msg.value == loanAmount, "Must send exact loan amount");

        loanFunded = true;
        emit LoanFunded(lender, msg.value);
    }

    /**
     * @dev Borrower repays the loan.
     */
    function repayLoan() external payable {
        require(loanFunded, "Loan not funded yet");
        require(!loanRepaid, "Loan already repaid");
        require(msg.sender == borrower, "Only borrower can repay");
        require(msg.value == loanAmount, "Must repay exact loan amount");

        loanRepaid = true;
        emit LoanRepaid(borrower, msg.value);

        // Transfer the repayment to the lender
        payable(lender).transfer(msg.value);
    }
}
