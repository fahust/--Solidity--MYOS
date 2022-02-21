
/**
 * TEST MONEY
 */

var myItems = {}
/*
let priceBaseTest = 1;
let totalSupply = 1;
let totalBalance = 0.7;
let pricenow = 1;

let myBalance = 1000;
let mytoken = 1;



function returnPriceNow(){
  pricenow = totalBalance/totalSupply
}
setVarRenderMoney()

function addTokenTest(){//achat avec du vrai argent (convert)
  returnPriceNow()
  totalSupply += 1;
  mytoken += 1;
  totalBalance += pricenow
  myBalance -= pricenow;
  setVarRenderMoney()
}

function gainTokenFree(){//gagner un token gratuitement
  totalSupply += 1;
  mytoken += 1;
  returnPriceNow()
  setVarRenderMoney()
}

function removeTokenTest(){//vente convert
  if(totalSupply>1&&mytoken>1){
    returnPriceNow()
    totalSupply -= 1;
    totalBalance -= pricenow;
    mytoken -= 1;
    myBalance += pricenow;
    setVarRenderMoney()
  }
}

function burnToken(){
  if(totalSupply>1&&mytoken>1){
    totalSupply--;
    mytoken--;
    setVarRenderMoney()
  }
}*/

async function depositItem(value,address){
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  let abi = await getAbi();
  let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
  //console.log(web3.utils.toWei(pricemint, "wei"))
  await contract.methods.depositItem(address).send({
    from: ethereum.selectedAddress,
    value:value,
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    getAllItems()
  });
}

async function buyItem(value,address){
  let abi = await getAbi();
  let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
  let priceCurrent = await contract.methods.getCurrentPrice(address).call({from: ethereum.selectedAddress})
  await contract.methods.buyItem(address,value).send({
    from: ethereum.selectedAddress,
    value:(priceCurrent*value),
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    getAllItems()
  });
}

async function sellItem(value,address){
  let abi = await getAbi();
  let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
  await contract.methods.sellItem(address,value).send({
    from: ethereum.selectedAddress,
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    getAllItems()
  });
}

async function gainItem(value){
  let abiItem = await getAbiItem();
  let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
  await contractItem.methods.mint(value,"0x3A109455BDB30500870B9807FFDa405D96175c44").send({
    from: ethereum.selectedAddress,
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{

  });
}

async function burnItem(value){
  let abiItem = await getAbiItem();
  let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
  await contractItem.methods.burn(value,"0x3A109455BDB30500870B9807FFDa405D96175c44").send({
    from: ethereum.selectedAddress,
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    
  });
}


/*async function ItemPriceAndBalance(address){
  await Moralis.enableWeb3()
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  if(connected == true){
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    let abiItem = await getAbiItem();
    let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
    balanceItem = await contract.methods.getBalanceOfItem(0).call({from: ethereum.selectedAddress})
    priceItem = await contractItem.methods.getCurrentPrice().call({from: ethereum.selectedAddress})
    $("#credit").html(balanceItem+" token on user account")
    $("#creditPrice").html((priceItem/1000000000000000000)+" matic for 1 token")
  }
}*/


function setVarRenderMoney(){
  returnPriceNow()
  $("#mymoney").html("my money :"+myBalance)
  $("#mytoken").html("my token :"+mytoken)
  $("#totaltoken").html("total supply token :"+totalSupply)
  $("#totalmoney").html("total money on smart contract :"+totalBalance)
  $("#currentprice").html("current price of token :"+pricenow/1000000000000000000)
  
}


async function getAllItems(){
  await Moralis.enableWeb3()
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  if(connected == true){
    let renderItems="";
    let abi = await getAbi();
    console.log(web3.eth)
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    let items = await contract.methods.getAddressItems().call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)});
    //console.log('items',items)
    await items.forEach((ITEM) => {
      contract.methods.getParamsItem(ITEM).call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)}).then((data)=>{
        myItems[ITEM] = data;
        renderItems += renderItem(data,ITEM)
      });
    })
    setTimeout(() => {
      $("#items").html(renderItems);
    }, 500);
  }
}

function renderItem(data,ITEM){
  console.log(data)
  return "<div class='card col-3'><strong class='card-header'>"+data[0]+"</strong>"
  +"<div class='card-body'>"
  +"<div>Rarity : "+data[1]+"</div>"
  +"<div>Current price : "+data[2]/1000000000000000000+" MATIC / "+((data[2]/1000000000000000000)*maticUsd).toFixed(2)+" USD</div>"
  +"<div>My balance : "+data[3]+"</div>"
  +"<div>Total balance : "+data[4]/1000000000000000000+" MATIC / "+((data[4]/1000000000000000000)*maticUsd).toFixed(2)+" USD</div>"
  +'<div><span class="badge badge-dark m-1 p-1" onclick="depositItem(100000000000000000,`'+(ITEM)+'`)">Déposer de l\'argent</span></div>'
  +'<div><span class="badge badge-dark m-1 p-1" onclick="buyItem(1,`'+(ITEM)+'`)" class="btn btn-dark">Acheter un item</span></div>'
  +'<div><span class="badge badge-dark m-1 p-1" onclick="sellItem(1,`'+(ITEM)+'`)" class="btn btn-dark">Vendre un item</span></div>'
  +'</div>'
  +'</div>'
  //+'<button onclick="convertItem()" class="btn btn-dark">convertir un item(non fonctionnel)</button>'
  //+'<button onclick="gainItem(1)" class="btn btn-dark">gagner un item</button>'
  //+'<button onclick="burnItem(1)" class="btn btn-dark">détruire un item</button>'
  ;
}

async function setItemAdmin(){
  await Moralis.enableWeb3()
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  if(connected == true){
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    //console.log($("#item-stats").val())
    await contract.methods.setItem(parseInt($("#item-id").val()),parseInt($("#item-name").val()),parseInt($("#item-symbol").val()),parseInt($("#item-rarity").val())).send({
      from: ethereum.selectedAddress,
    }).catch((error)=>{console.log('error transfer',error)}).then(()=>{
      //renderGame()
    });
  }
}