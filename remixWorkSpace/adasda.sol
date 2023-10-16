// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
error DepositError(string err);
contract room is Ownable {
   //uint256 public totalDeposit; // 总余额

   mapping(address => uint256) public deposit; //表示总下注多少钱
   mapping(address =>address) public pairs; 
   mapping (address => bool) public isBet;
   mapping (address => bool) public openBetTwice;
   mapping(address=>bool) isEndBet; 

   // 当两两组队时（即点击准备后就开始,在准备的时候同时下第一次注，前端调用此函数 
   function addpairs(address account1,address account2) external onlyOwner {
      pairs[account1]=account2;
      pairs[account2]=account1;
      openBetTwice[account1] = true;
      openBetTwice[account2] = true;
   }
   // 初始下注
   function addshare1() external payable {
      if(msg.value !=  0.01 ether){
         revert DepositError("Not 0.01 ether");
      } 
         deposit[msg.sender]+=0.01 ether;
         isBet[msg.sender] = true; 
   }

   function getDeposit(address addr) public view returns(uint256){
      return deposit[addr];
   }
   // 若一方等太久，可选择退出游戏
   function finish() external {
      require(pairs[msg.sender] == address(0),"Opponent has bet");
      isBet[msg.sender] = false;
      uint256 Amount = getDeposit(msg.sender);
      payable (msg.sender).transfer(Amount);
   }
   // 游戏开始
   /**
    * 此时玩家已知晓自己的牌
    * 这里传入zk生成的证明
    */



   // 之后加注,
   /**e
    * 若对方全押，则自己选择跟与不跟，此时游戏结束
    * 涉及先押还是后押问题？
    */
   // 可重复调用
   function addshare2() external payable {
      // 开启此函数调用的时候要搞个时间差
      address opponent = pairs[msg.sender]; 
      // 先检测第一次下注没有
      require(
         isBet[msg.sender],
         "You haven't made your first bet yet"
         );
         // 表示均已交钱并组成对赌
      require(opponent != address(0)); 

         // 检测第二次下注没有
      // require(
      //    !isBetTwice[msg.sender], 
      //    "You've raised the bet for the second time"
      // );

      // 检测对手是否加注
       // 若对手未加注，则我可以选择加注，反之。此时有时间限制

      uint256 oldOpponentAmount = deposit[opponent]

      function giveup() external{}