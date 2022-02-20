//const Token = artifacts.require("Token");//0.093
const TokenDelegable = artifacts.require("TokenDelegable");
const DelegateContract = artifacts.require("DelegateContract");
const ClassesContract = artifacts.require("ClassesContract");
const QuestContract = artifacts.require("QuestContract");
const Items = artifacts.require("Items");

 function getRandomArbitrary(min, max) {
  return Math.random() * (max - min) + min;
}

function randRang(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
module.exports = async function (deployer) {
  await deployer.deploy(TokenDelegable, "MYOS","MYOS","https://tam.nyxiesnft.com/img/generated/");
  let TokenDelegableInstance = await TokenDelegable.deployed();
  
  await deployer.deploy(ClassesContract, TokenDelegableInstance.address);
  let ClassesContractInstance = await ClassesContract.deployed();
  
  ClassesContractInstance.setClass(0,[1,2,1,3,2,1]);
  await deployer.deploy(QuestContract, TokenDelegableInstance.address);
  let QuestContractInstance = await QuestContract.deployed();
  
  await deployer.deploy(Items,100000, "CREDIT","CRDT");
  let ItemsInstance = await Items.deployed();

  await ItemsInstance.mint(2,"0x3A109455BDB30500870B9807FFDa405D96175c44")
  /*ItemsInstance.send(700000000).then(function(result) {
    // Same result object as above.
  });*/
  
  await deployer.deploy(DelegateContract, TokenDelegableInstance.address,QuestContractInstance.address,ClassesContractInstance.address);
  let DelegateContractInstance = await DelegateContract.deployed();
  TokenDelegableInstance.setAdressDelegateContract(DelegateContractInstance.address)
  //console.log(ItemsInstance.address)
  await DelegateContractInstance.setAddressItem(ItemsInstance.address,1)
  //await DelegateContractInstance.giveToken("0x3A109455BDB30500870B9807FFDa405D96175c44",0)
  //await DelegateContractInstance.giveToken("0x3A109455BDB30500870B9807FFDa405D96175c44",0)
  await QuestContractInstance.setQuest(0,1000,100,50,[0,0,0,0,0,0])
  await QuestContractInstance.setQuest(1,1000,100,50,[0,0,0,0,0,0])
  /*let price = await ItemsInstance.getBalanceOf("0x3A109455BDB30500870B9807FFDa405D96175c44");
  console.log(price)
  let address = await DelegateContractInstance.getAddressItem(1);
  console.log(address)
  //console.log(ItemsInstance.address)
  let balance = await DelegateContractInstance.getBalanceOfItem(1)
  console.log(balance)*/

  
  //console.log(await ClassesContractInstance.getClassDetails(0));
  //DelegateContractInstance.mintDelegate(1,1,1)
  //await DelegateContractInstance.giveNyxie(0,"0x400919F8f5740436d1A1769bC241477275C61545"); // Token id 0
  //await tokenInstance.mint(1); // Token id 0
  //await tokenInstance.reproduce([1,2,1,0,1,3],0, [1,2,1,0,1,3], "0x400919F8f5740436d1A1769bC241477275C61545", 1);
  //let mystic = await tokenInstance.getTokenDetails(0);
  //let mystic = await tokenInstance.getTokenDetails(2);
  //console.log(mystic)

};
