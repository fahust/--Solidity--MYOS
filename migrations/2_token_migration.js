//const Token = artifacts.require("Token");//0.093
const TokenDelegable = artifacts.require("TokenDelegable");
const DelegateContract = artifacts.require("DelegateContract");

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
  await deployer.deploy(DelegateContract, TokenDelegableInstance.address);
  //console.log(tokenInstance.address)
  let DelegateContractInstance = await DelegateContract.deployed();
  TokenDelegableInstance.setAdressDelegateContract(DelegateContractInstance.address)
  //await DelegateContractInstance.giveNyxie(0,"0x400919F8f5740436d1A1769bC241477275C61545"); // Token id 0
  //await tokenInstance.mint(1); // Token id 0
  //await tokenInstance.reproduce([1,2,1,0,1,3],0, [1,2,1,0,1,3], "0x400919F8f5740436d1A1769bC241477275C61545", 1);
  //let mystic = await tokenInstance.getTokenDetails(0);
  //let mystic = await tokenInstance.getTokenDetails(2);
  //console.log(mystic)

};
