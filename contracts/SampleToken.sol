// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

 /**
 * @title  ORIZ TOKEN
 * @notice Contract to implement ERC 20 standards on the Arbitrum chain
 * @dev 
    2% fee auto distribute to all holders
    1% burn on all transactions
 */

contract ARBITRUM is ERC20{
    // unsigned integer to hold decimal value of token
    uint8 decimal; 
    uint burn_total;
    uint burn_fee;
    address devadd;
    uint total_supply;
    address Oriz_owner;

    /**
    * @dev add new token details during deployment
    * Params:
    *       @param initialSupply Admin address for owner contract
    *       @param name usdt address of token
    *       @param symbol shows the decimal value of the chosen USDT token
    *       @param _decimal holds the fee each user pays on signup
    */
    constructor(
        string memory name, 
        string memory symbol, 
        uint8 _decimal,
        uint initialSupply, 
        uint _burnfee,
        address _owner
         ) ERC20(name, symbol) 
         {
        _mint(_owner, (initialSupply * 10 ** _decimal));
        Oriz_owner = _owner;
        decimal = _decimal;
        burn_fee = _burnfee;
        devadd = msg.sender;
        total_supply = initialSupply * 10 ** (_decimal);
        emit Transfer(address(0), Oriz_owner, initialSupply);

    }

    function decimals() public view virtual override returns (uint8) {
        return decimal;
    }

    function transfer(address recipient, uint amount) public override returns (bool) {
        require(balanceOf(msg.sender) >= amount, "LPT: transfer amount exceeds balance");
        uint burnpercent = amount * burn_fee ** 100;
        uint famount = amount - burnpercent;
        uint burn_limit = total_supply - (total_supply*(burn_total)/(100));
        if (this.totalSupply() > burn_limit){
          _burn (msg.sender, burnpercent);
          _transfer(msg.sender, recipient, famount);
          emit Transfer(msg.sender, recipient, amount);
        }
        else{
          _transfer(msg.sender, recipient, amount);
          emit Transfer(msg.sender, recipient, amount);
        }
        return true;
    }

    function transferFrom(address from, address to, uint amount) public virtual override returns (bool) {
        uint burnpercent = amount*(burn_fee)/(100);
        uint famount = amount - burnpercent;
        uint burn_limit = total_supply - (total_supply * burn_total / 100);
        address spender = _msgSender();
        if (this.totalSupply() > burn_limit){
          _burn (msg.sender, burnpercent);
          _spendAllowance(from, spender, amount);
          _transfer(msg.sender, to, famount);
          emit Transfer(msg.sender, to, amount);
        }
        else{
          _spendAllowance(from, spender, amount);
          _transfer(msg.sender, to, amount);
          emit Transfer(msg.sender, to, amount);
        }
        return true;
    }

    function updateFeeOnTransfer(uint _burn_total, uint _burn_percent) public {
        burn_total =_burn_total;
        burn_fee = _burn_percent;
    }

    function updateDevAdd(address _devadd) public {
        devadd = _devadd;
    }
}
