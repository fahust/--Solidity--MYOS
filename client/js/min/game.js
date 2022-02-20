
             //await ethereum.enable();

/** Connect to Moralis server */
//Mettre côter serveur, a récupérer avant tout autre choses avec un fetch puis lancer la function startMain
const serverUrl = "https://9rotklamvhur.usemoralis.com:2053/server";
const appId = "32qjS96gLON4ZUxrPSXbqM73w1h3HGDpFlbQ9tMM";
const CONTRACT_ADDRESS = "0x11c81DEeb9C3A1e75653eA781b6836488F25b84A";
const CONTRACT_ADDRESS_ITEM = "0x081172544E7d9B18e0e87756D21448488Bb6754e";
const CONTRACT_ADDRESS_QUEST = "0x4e1CCdD1B31a0E7B660baB305A1320c3D348479d";


//DEV : 0x4EfC6600b04b14d786Fd0fc77790ca2f68335518
//PROD : 0x3ac4b0c407b3327FB714c53568531Ac39294C5d0//0xaC84A40eC35f0ae77aD22A08E1E3c6D280644b5b//

/**
 * VARIABLE ET CONSTANTE
 */
var myMysticId = undefined;
var gasPriceNow = 0;
var myHeroes = {};

window.addEventListener('load', async () => {
  startMain();
});


var web3 = undefined;

var img1 = "";
var img2 = "";
var img3 = "";
var img4 = "";
var img5 = "";
//var canvas = document.getElementById("canvas");
//var ctx = canvas.getContext("2d");


var life = 0;
var hungry = 0;
var cleanliness = 0;
var moral = 0;
var rested = 0;
var eggs = {};
var foods = {};
var items = {};
var myMystic = {};
var invitsReceive = undefined;
var invitsSended = undefined;
var foodByZone = undefined;
var myMysticData = undefined;
var priceEth = 0;
var paramsContract = undefined;
var pricemint = 0;
var balanceItem = 0;

/**
 * END OF VARIABLE
 */



/**
 * TEST MONEY
 */
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

async function depositItem(value){
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  let abiItem = await getAbiItem();
  let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
  //console.log(web3.utils.toWei(pricemint, "wei"))
  await contractItem.methods.deposit().send({
    from: ethereum.selectedAddress,
    value:value,
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    ItemPriceAndBalance()
  });
}

async function buyItem(value){
  let abiItem = await getAbiItem();
  let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
  let priceCurrent = await contractItem.methods.getCurrentPrice().call({from: ethereum.selectedAddress})
  await contractItem.methods.buyItem(value).send({
    from: ethereum.selectedAddress,
    value:(priceCurrent*value),
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    ItemPriceAndBalance()
  });
}

async function sellItem(value){
  let abiItem = await getAbiItem();
  let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
  await contractItem.methods.sellItem(value).send({
    from: ethereum.selectedAddress,
  }).catch((error)=>{
    console.log('error transfer',error)
    console.log(error.message)
  }).then(()=>{
    ItemPriceAndBalance()
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
    ItemPriceAndBalance()
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
    ItemPriceAndBalance()
  });
}




function setVarRenderMoney(){
  returnPriceNow()
  $("#mymoney").html("my money :"+myBalance)
  $("#mytoken").html("my token :"+mytoken)
  $("#totaltoken").html("total supply token :"+totalSupply)
  $("#totalmoney").html("total money on smart contract :"+totalBalance)
  $("#currentprice").html("current price of token :"+pricenow)
  
}


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


async function ItemPriceAndBalance(){
  await Moralis.enableWeb3()
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  if(connected == true){
    let abi = await getAbi();
    let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
    let abiItem = await getAbiItem();
    let contractItem = new web3.eth.Contract(abiItem, CONTRACT_ADDRESS_ITEM);
    balanceItem = await contract.methods.getBalanceOfItem(1).call({from: ethereum.selectedAddress})
    priceItem = await contractItem.methods.getCurrentPrice().call({from: ethereum.selectedAddress})
    $("#credit").html(balanceItem+" token on user account")
    $("#creditPrice").html((priceItem/1000000000000000000)+" matic for 1 token")
  }
}

/**
 * Démarrage de la page index
 */
 async function startMain(){
  await Moralis.enableWeb3()
  window.web3 = new Web3(Moralis.provider)
  let connected = await window.web3.eth.net.isListening();
  //document.getElementById("btn-login").onclick = login;
  //document.getElementById("btn-log-meta").onclick = login;
  //document.getElementById("btn-logout").onclick = logOut;

    if(connected == true){console.log("connected")
      web3.eth.getGasPrice().then((result) => {console.log(result)
          gasPriceNow = (result)
      })

        let abi = await getAbi();
        let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
        window.web3 = await Moralis.Web3.enableWeb3();
        pricemint = await contract.methods.getParamsContract("price").call({from: ethereum.selectedAddress})
        ItemPriceAndBalance()

        /*let test = await window.web3.getBalance("0xe82ADf2C9918AdED35C88bB8567fdd6aE31b5b58")
        console.log('getbalance',test);*/
        /*let eggOneRemain = await contract.methods.getParamsContract("eggOneRemain").call({from: ethereum.selectedAddress});
        let eggTwoRemain = await contract.methods.getParamsContract("eggTwoRemain").call({from: ethereum.selectedAddress});
        let eggThreeRemain = await contract.methods.getParamsContract("eggThreeRemain").call({from: ethereum.selectedAddress});
        */
        /*$(".iconic-egg-remain").html("Soon ( "+(eggOneRemain)+" / 1000 )")
        $(".rare-egg-remain").html("Soon ( "+(eggTwoRemain)+" / 3000 )")
        $(".classic-egg-remain").html("Soon ( "+(eggThreeRemain)+" / 6000 )")*/
  }

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
   * Login 
   */
  async function login() {
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
    try {
       // user = await Moralis.authenticate({ signingMessage: "Connect to mystic tamable !" })
        renderGame();
    } catch(error) {
      console.log(error)
    }
    }else{
      renderGame();
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
   * récuperer Le json des metadata pendant le mint
   */
  function getMeta(){
    return new Promise((res)=>{
      $.getJSON("img/generated/_metadata.json",((json)=>{
        res(json)
      }))
    })
    
  }


  async function mint(){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    //console.log(connected)
    if(connected == true){
      let abi = await getAbi();
      let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
      await contract.methods.mintDelegate(0,0,0).send({
        from: ethereum.selectedAddress,
        value:web3.utils.toWei(pricemint, "wei"),
        //gasPrice: '1000000000',//gwei 1
        //gasPrice: '30',
        //gas: 1000000,
      }).catch((error)=>{
        console.log('error transfer',error)
        console.log(error.message)
      }).then(()=>{
        //renderGame()
      });
    }
  }

  setTimeout(() => {
    getAllHero();
  }, 500);

  async function getAllHero(){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
      let renderHeroes="";
      let abi = await getAbi();
      console.log(web3.eth)
      let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
      let heroes = await contract.methods.getAllTokensForUser(ethereum.selectedAddress).call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)});
      await heroes.forEach((MYO) => {
        contract.methods.getTokenDetails(MYO).call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)}).then((data)=>{
          myHeroes[MYO] = data;
          console.log(data)
          renderHeroes += renderHero(data)
          //timeOut++
          /*setTimeout(() => {
            sendToServerMeta(data,MYO)
          }, 2000*timeOut);*/
          //break;//A DEGAGER
        });
      })
      setTimeout(() => {
        console.log(renderHeroes)
        $("#heroes").html(renderHeroes);
      }, 500);
    }
  }

  function renderHero(data){
    return "<strong>#"+data.params256[6]+"</strong>"
    +"<div>STR : "+data.params8[0]+"</div>"
    +"<div>DEX : "+data.params8[1]+"</div>"
    +"<div>AGI : "+data.params8[2]+"</div>"
    +"<div>END : "+data.params8[3]+"</div>"
    +"<div>INT : "+data.params8[4]+"</div>"
    +"<div>? : "+data.params8[5]+"</div>"
    +"<div>In Quest : "+data.params256[3]+"</div>"
    +"<div>Time for finish : "+data.params256[4]+"</div>"
    ;
  }


  /**
   * QUEST
   */
  
  setTimeout(() => {
    getAllQuestAdmin();
  }, 3000);
  async function getAllQuestAdmin(){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
      let abi = await getAbiQuest();
      let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS_QUEST);
      let quests = await contract.methods.getAllQuests().call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)});
      let renderQuests="";
      await quests.forEach((QST) => {
        contract.methods.getQuestDetails(QST).call({from: ethereum.selectedAddress}).catch((error)=>{console.log(error)}).then((data)=>{
          console.log(data)
          if(data.id!=0) renderQuests += renderQuest(data)
        });
      })
      setTimeout(() => {
        console.log(renderQuests)
        $("#quests").html(renderQuests);
      }, 500);
    }
  }

  function statSring(index){
    if(index == 0) return "STR";
    if(index == 1) return "DEX";
    if(index == 2) return "STR";
    if(index == 3) return "STR";
    if(index == 4) return "STR";
    if(index == 5) return "STR";
    
  }

  function renderQuest(data){
    return "<div class='quest-"+data.id+"'><strong>#"+data.id+"</strong>"
    +"<div>Success : "+data.percentDifficulty+" %</div>"
    +"<div>Seconds to finish : "+data.time+"</div>"
    +"<div>Valid : "+data.valid+"</div>"
    +requirementStats(data)
    +selectHero()
    +startOrCompleteRender(data)
    +'</div>'
    //+data.stats.map((value,key)=>{return "<div>"+statSring(key)+" required : "+value+"</div>"})
    ;
  }

  setInterval(() => {
    $(".waiting").each(function( index ) {
      let secLeft = (parseInt($(this).html().replace(/\D/g, ""))-1)
      if(secLeft < 0){
        getAllQuestAdmin()
      }else{
        $(this).html("wait "+secLeft+" sec.");
      }
      
    })
    
  }, 1000);

  function startOrCompleteRender(data){
    inQuest = false;
    Object.keys(myHeroes).forEach(MYO => {
      if(myHeroes[MYO].params256[3]==data.id){
        inQuest = myHeroes[MYO].params256[6];
      }
    });

    if(myHeroes[inQuest]){
      console.log("now",new Date().getTime()/1000 )
      console.log("lastaction",myHeroes[inQuest].params256[2])
      console.log("time mission",data.time)
      console.log((new Date().getTime()/1000)-myHeroes[inQuest].params256[2])
    }

    if(inQuest==false){
      return '<button onclick="startQuest('+data.id+')" class="btn btn-dark">start quest</button>';
    }else if((new Date().getTime()/1000)-myHeroes[inQuest].params256[2] < data.time ){
      return '<button onclick="" class="btn btn-dark waiting">wait '+Math.floor((data.time) - ((new Date().getTime()/1000)-myHeroes[inQuest].params256[2]))+' sec.</button>';
    }else{
      return '<button onclick="completeQuest('+data.id+','+inQuest+')" class="btn btn-dark">complete quest</button>';
    }
  }

  function selectHero(){
    retour = "<select class='hero-quest-select'>"
    Object.keys(myHeroes).forEach(MYO => {
      if(myHeroes[MYO].params256[3]==0){
        retour += "<option value='"+myHeroes[MYO].params256[6]+"'>#"+myHeroes[MYO].params256[6]+"</option>"
      }
    });
    retour += "</select>"
    return retour;
  }

  function requirementStats(data){
    retour = "";
    data.stats.forEach((value,key) => {
      if(value>0)retour += "<div>"+statSring(key)+" required : "+value+"</div>"
    });
    return retour;
  }

  async function startQuest(questId){
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
      let abi = await getAbi();
      let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
      console.log($(".quest-"+questId+" select").val())
      await contract.methods.startQuest(parseInt(questId),$(".quest-"+questId+" select").val()).send({
        from: ethereum.selectedAddress,
      }).catch((error)=>{console.log('error transfer',error)}).then(()=>{
        //renderGame()
      });
    }
  }

  async function completeQuest(questId,tokenId){
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
      let abi = await getAbi();
      let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS);
      console.log("complete quest")
      await contract.methods.completeQuest(parseInt(tokenId)).send({
        from: ethereum.selectedAddress,
      }).catch((error)=>{console.log('error transfer',error)}).then(()=>{
        //renderGame()
      });
    }
  }

  async function setQuestAdmin(){
    await Moralis.enableWeb3()
    window.web3 = new Web3(Moralis.provider)
    let connected = await window.web3.eth.net.isListening();
    if(connected == true){
      let abi = await getAbiQuest();
      let contract = new web3.eth.Contract(abi, CONTRACT_ADDRESS_QUEST);
      console.log($("#quest-stats").val())
      await contract.methods.setQuest(parseInt($("#quest-id").val()),parseInt($("#quest-time").val()),parseInt($("#quest-exp").val()),parseInt($("#quest-percentDifficulty").val()),JSON.parse($("#quest-stats").val())).send({
        from: ethereum.selectedAddress,
      }).catch((error)=>{console.log('error transfer',error)}).then(()=>{
        //renderGame()
      });
    }
  }