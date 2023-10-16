// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./verifier.sol";
error DepositError(string err);
/**
 * 
 */
contract room is Ownable { 
   //uint256 public totalDeposit; // 总余额

   mapping(address => uint256) public deposit; //表示总下注多少钱
   mapping(address =>address) public pairs; 
   // mapping (address => bool) public isBet;
   mapping (address => bool) public openAfterBet;
   mapping(address=>bool) public isEndBet;
   // 表示已经第几轮加注 
   mapping(address=>uint256) public count;
   bool public isFalsify; 
   string userZk11;
   string userZk12;
   string userZk21;
   string userZk22; 

   // 当两两组队时（即点击准备后就开始,在准备的时候同时下第一次注，前端调用此函数 
   function addpairs(address account1,address account2) external onlyOwner {
      pairs[account1]=account2;
      pairs[account2]=account1;

      openAfterBet[account1] = true;
      openAfterBet[account2] = true; 
   }
   // 初始下注
   function addshare1() external payable {
      if(msg.value !=  0.01 ether){
         revert DepositError("Not 0.01 ether");
      } 
         deposit[msg.sender]+=0.01 ether;
         count[msg.sender] += 1 ; 
   }

   function getDeposit(address addr) public view returns(uint256){
      return deposit[addr];
   }
   // 若一方等太久，可选择退出游戏
   function finish() external {
      require(pairs[msg.sender] == address(0),"Opponent has bet");
      count[msg.sender] = 0; 
      uint256 Amount = getDeposit(msg.sender);
      payable(msg.sender).transfer(Amount);
      deposit[msg.sender] = 0;
   }
   // 游戏开始
   /**
    * 此时玩家已知晓自己的牌
    * 这里传入zk生成的证明
    */
   function reciveZK(string memory user11,string memory user12,string memory user21,string memory user22) external onlyOwner{
      userZk11 = user11;
      userZk12 = user12;
      userZk21 = user21;
      userZk22 = user22; 
   }

   // 验证谁输谁赢
   function judg(address verifierAddr,uint[3][2] memory proof, uint[3] memory input) public {
       (, bytes memory data)=verifierAddr.call( 
         abi.encodeWithSignature("verifyTx()", proof,input)
       ); 
        isFalsify = abi.decode(data, (bool));
   }

   function gameOver(address winner, address loser) external onlyOwner{
      if (isFalsify) {
         liquidation2(winner,loser); 
      }
   }


   // 之后加注第三次以后
   // 可重复调用
   function addshare2() external payable {
      // 开启此函数调用的时候要搞个时间差
      address opponent = pairs[msg.sender]; 
      // 先检测第一次下注没有
      require(
         count[msg.sender] == 1,
         "You haven't made your first bet yet"
         );
      // 表示均已交钱并组成对赌
      require(opponent != address(0)); 
      // 检测是否已终止二次加注
      require(!isEndBet[msg.sender] && !isEndBet[opponent]);
      uint256 oldOpponentAmount = deposit[opponent];
      if (count[msg.sender] + 1 == count[opponent]) { 
            // 对手已加注
            uint256 opponentCurrentAmount = deposit[opponent]- oldOpponentAmount;
            uint256 MyBalance = (pairs[msg.sender]).balance;
            if (MyBalance>opponentCurrentAmount) {
               // require(msg.value == opponentTwiceAmount);
               if (msg.value<opponentCurrentAmount) {
                  revert DepositError("Your bet is too small");
               }else if (msg.value == opponentCurrentAmount) {
                  isEndBet[msg.sender] = true; 
                  isEndBet[opponent] = true;
                  deposit[msg.sender] += msg.value; 
               }else {
                  count[msg.sender] += 1;
               }             
            }else {
               // 钱不够，则全押，结束押注
               require(msg.value == MyBalance); 
               isEndBet[msg.sender] = true;
               isEndBet[opponent] = true;
               deposit[msg.sender] += msg.value; 
               count[msg.sender] += 1; 
            }
            
         }else {
            // 两方均未加注
            require(msg.value > 0.01 ether,"too low");
            deposit[msg.sender] += msg.value; 
            count[msg.sender] += 1; 
         }
            
   }
   // 认输,所有状态都回滚，并结算
   function giveUp() external {
      isEndBet[msg.sender]=true; 
      openAfterBet[msg.sender] = false;
      address opponent = pairs[msg.sender]; 
      liquidation1(opponent, msg.sender); 
   }
   // 赌博过程结束，结算函数
   function liquidation1(address winner,address loser) internal {
      uint256 endAmount = deposit[winner] + deposit[loser];  
      payable(winner).transfer(endAmount); 
      deposit[winner]=0;
      deposit[loser]=0;
   }
   function liquidation2(address winner,address loser) internal{
      require(count[winner]!=1);
      require(count[loser]!=1); 
      require(count[winner]==count[loser]);
      uint256 endAmount = (deposit[winner] + deposit[loser]) * 80/100;  
      payable(winner).transfer(endAmount); 
      deposit[winner]=0;
      deposit[loser]=0;
   }
}