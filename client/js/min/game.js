
             //await ethereum.enable();

/** Connect to Moralis server */
//Mettre côter serveur, a récupérer avant tout autre choses avec un fetch puis lancer la function startMain
const serverUrl = "https://9rotklamvhur.usemoralis.com:2053/server";
const appId = "32qjS96gLON4ZUxrPSXbqM73w1h3HGDpFlbQ9tMM";
const CONTRACT_ADDRESS = "0x2fe211d699465f63db3cE00D6AC4Ebdef787CB0a";
const CONTRACT_ADDRESS_ITEM = "0xfF7a619D6E224ebdf88BCaC8b644d8346bBD1711";
const CONTRACT_ADDRESS_QUEST = "0xa751e42194880E858dce59731b15716b2A1617ee";
const CONTRACT_ADDRESS_CLASS = "0x3D6aA7C6Cb9A54cF559ba32De7b781da055B840f";

//DEV : 0x4EfC6600b04b14d786Fd0fc77790ca2f68335518
//PROD : 0x3ac4b0c407b3327FB714c53568531Ac39294C5d0//0xaC84A40eC35f0ae77aD22A08E1E3c6D280644b5b//

/**
 * VARIABLE ET CONSTANTE
 */
var myMysticId = undefined;
var gasPriceNow = 0;
var myHeroes = {};
var maticEur = 0;
var maticUsd = 0;


window.addEventListener('load', async () => {
  startMain();
});

fetch('https://api.coinbase.com/v2/exchange-rates?currency=MATIC', {
  method: 'get',
  headers: {
    'Accept': 'application/json, text/plain, */*',
    'Content-Type': 'application/json'
  },
}).then(res => res.json())
.then(res => {
  maticEur = (res.data.rates.EUR)
  maticUsd = (res.data.rates.USD)
});


var web3 = undefined;

/*var img1 = "";
var img2 = "";
var img3 = "";
var img4 = "";
var img5 = "";*/
//var canvas = document.getElementById("canvas");
//var ctx = canvas.getContext("2d");



var priceEth = 0;
var paramsContract = undefined;
var pricemint = 0;
var balanceItem = 0;

/**
 * END OF VARIABLE
 */




/**
 * FONCTION OUTILS
 */


function randRang(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomArbitrary(min, max) {
  return Math.random() * (max - min) + min;
}

function timeSince(date) {

  var seconds = Math.floor((new Date() - date) / 1000);

  var interval = seconds / 31536000;

  if (interval > 1) {
    return Math.floor(interval) + " years";
  }
  interval = seconds / 2592000;
  if (interval > 1) {
    return Math.floor(interval) + " months";
  }
  interval = seconds / 86400;
  if (interval > 1) {
    return Math.floor(interval) + " days";
  }
  interval = seconds / 3600;
  if (interval > 1) {
    return Math.floor(interval) + " hours";
  }
  interval = seconds / 60;
  if (interval > 1) {
    return Math.floor(interval) + " minutes";
  }
  return Math.floor(seconds) + " seconds";
}
/**
 * FIN DES FONCTIONS OUTILS
 */



/**
 * Démarrage de la page index
 */
 async function startMain(){
  await Moralis.enableWeb3()
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();

    if(connected == true){console.log("connected")
      web3.eth.getGasPrice().then((result) => {console.log(result)
          gasPriceNow = (result)
      })

        let abi = await getAbi();
        let abiclass = await getAbiClass();
        let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
        let contractClass = new web3.eth.Contract(abiclass, CONTRACT_ADDRESS_CLASS);
        window.web3 = await Moralis.Web3.enableWeb3();
        pricemint = await contract.methods.getParamsContract("price").call({from: ethereum.selectedAddress})
        getAllHero();
        
        /*await Moralis.enableWeb3()
        window.web3 = new Web3(Moralis.provider)*/
        setTimeout(() => {
          contractClass.methods.getAllClass().call({from: ethereum.selectedAddress}).then((allClasses)=>{
            selectClass(allClasses);
          })
        }, 500);
  }

}





  /**
   * Login 
   */
  async function login() {
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
    try {
       // user = await Moralis.authenticate({ signingMessage: "Connect to mystic tamable !" })
        startMain();
    } catch(error) {
      console.log(error)
    }
    }else{
      startMain();
    }
  }

  /**
   * logout
   */
  async function logOut() {
    await Moralis.User.logOut();
    $(".unlogged-btn").fadeIn("fast");
    $(".logged-btn").fadeOut("fast");

    $("#contentBody").fadeOut("fast");
    $("#myMystics").html('');
  }

  /**
   * GENERATE META DATA OF TOKEN 
   * @param {*} egg 
   * @param {*} id 
   * @returns 
   */
  function generateMetaData(egg,id){
    return {
      "name": "NYXIES #"+id,
      "description": "Nyxies are mystical and tame creatures that can be reproduced ad infinitum",
      "image": "https://tam.nyxiesnft.com/img/generated/"+id+".png",
      "edition": 0,
      "seller_fee_basis_points": 250,
      "collection": {
          "name": "NYXIES",
          "family": "EGGS"
      },
      "symbol": "NYXS",
      "properties": {
          "files": [
              {
                  "uri": "https://tam.nyxiesnft.com/img/generated/"+id+".png",
                  "type": "image/png"
              }
          ],
          "category": "image",
          "creators": [
              {
                  "address": "0x0cE1A376d6CC69a6F74f27E7B1D65171fcB69C80",
                  "share": 100
              }
          ]
      },
      "attributes": [
          {
              "trait_type": "egg",
              "value": (parseInt(egg.params8[0])+(parseInt(egg["params256"][7])==2||parseInt(egg["params256"][7])==1?0:4))
          },
          {
              "trait_type": "ears",
              "value": idPartsToNameParts(egg.params8[1])
          },
          {
              "trait_type": "horn",
              "value": idPartsToNameParts(egg.params8[2])
          },
          {
              "trait_type": "mouth",
              "value": idPartsToNameParts(egg.params8[3])
          },
          {
              "trait_type": "eyes",
              "value": idPartsToNameParts(egg.params8[4])
          }
      ]
  }
  }
  
  
  /**
   * récuperer Le abi (ensemble des fonctions du smart contract)
   */
  function getAbi(){
    return new Promise((res)=>{
      $.getJSON("js/Delegate_contract.json",((json)=>{
        res(json.abi)
      }))
    })
    
  }
  
  /**
   * récuperer Le abi (ensemble des fonctions du smart contract)
   */
  function getAbiItem(){
    return new Promise((res)=>{
      $.getJSON("js/Items.json",((json)=>{
        res(json.abi)
      }))
    })
    
  }
  
  
  /**
   * récuperer Le abi (ensemble des fonctions du smart contract)
   */
  function getAbiQuest(){
    return new Promise((res)=>{
      $.getJSON("js/QuestContract.json",((json)=>{
        res(json.abi)
      }))
    })
    
  }
  
  /**
   * récuperer Le abi (ensemble des fonctions du smart contract)
   */
  function getAbiClass(){
    return new Promise((res)=>{
      $.getJSON("js/ClassesContract.json",((json)=>{
        res(json.abi)
      }))
    })
    
  }
  /**
   * récuperer Le json des metadata pendant le mint
   */
  function getMeta(){
    return new Promise((res)=>{
      $.getJSON("img/generated/_metadata.json",((json)=>{
        res(json)
      }))
    })
    
  }


  function statSring(index){
    if(index == 0) return "STR";
    if(index == 1) return "DEX";
    if(index == 2) return "STR";
    if(index == 3) return "STR";
    if(index == 4) return "STR";
    if(index == 5) return "STR";
    
  }
