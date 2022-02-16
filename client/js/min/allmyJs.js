

/** Connect to Moralis server */
//Mettre côter serveur, a récupérer avant tout autre choses avec un fetch puis lancer la function startMain
const serverUrl = "https://9rotklamvhur.usemoralis.com:2053/server";
const appId = "32qjS96gLON4ZUxrPSXbqM73w1h3HGDpFlbQ9tMM";
const CONTRACT_ADDRESS = "0x3ac4b0c407b3327FB714c53568531Ac39294C5d0";
//DEV : 0x4EfC6600b04b14d786Fd0fc77790ca2f68335518
//PROD : 0x3ac4b0c407b3327FB714c53568531Ac39294C5d0//0xaC84A40eC35f0ae77aD22A08E1E3c6D280644b5b//

/**
 * VARIABLE ET CONSTANTE
 */
var myMysticId = undefined;
var gasPriceNow = 0;

var web3 = undefined;

var img1 = "";
var img2 = "";
var img3 = "";
var img4 = "";
var img5 = "";


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

  function navAllUnactive(){
    $(".nav-link").each(function(){
      $(this).removeClass("active")
    })
  }

  /**
   * Génération de la modal avec contenu FAQ
   */
  async function faq(){
      $(".modal-title").html("FAQ");
      $.get('js/min/faq.html', function(data) {
        $(".modal-body").html(data);
      }); 
  }

  async function updates(){
      $(".modal-title").html("UPDATES");
      $.get('js/min/updates.html', function(data) {
        $(".modal-body").html(data);
      }); 
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
   * récuperer Le json des metadata pendant le mint
   */
  function getMeta(){
    return new Promise((res)=>{
      $.getJSON("img/generated/_metadata.json",((json)=>{
        res(json)
      }))
    })
    
  }

  

$(".convert-eth").each(function(){
    //console.log(($(this).data("price")))
    $(this).html(($(this).data("price"))+" MATIC")
  })



$("#title-mystic").fadeIn("fast", function() {
  $("#subtitle-mystic").fadeIn("fast", function() {

  })
})



  var depth, layer, layers, movement, topDistance, translate3d, _i, _len;
  //layers = document.querySelectorAll("[data-type='parallax']");
  (function() {
    window.addEventListener('scroll', function(event) {
      topDistance = this.pageYOffset;
      /*for (_i = 0, _len = layers.length; _i < _len; _i++) {
        layer = layers[_i];
        depth = layer.getAttribute('data-depth');
        movement = -(topDistance * depth);
        translate3d = 'translate3d(0, ' + movement + 'px, 0)';
        layer.style['-webkit-transform'] = translate3d;
        layer.style['-moz-transform'] = translate3d;
        layer.style['-ms-transform'] = translate3d;
        layer.style['-o-transform'] = translate3d;
        layer.style.transform = translate3d;
      }*/
      if(window.scrollY < window.innerHeight ){
        $("#background-opacity").css('opacity', (100-(window.scrollY/(window.innerHeight/600)))/100);
        $("#section-title").css('opacity', (100-(window.scrollY/(window.innerHeight/600)))/100);
        
        $(".hero-move-one").css('opacity', ((window.scrollY/(window.innerHeight/600)))/100);
        $(".hero-move-two").css('opacity', ((window.scrollY/(window.innerHeight/600)))/100);
        $(".hero-move-three").css('opacity', ((window.scrollY/(window.innerHeight/600)))/100);
        $(".hero-move-four").css('opacity', ((window.scrollY/(window.innerHeight/600)))/100);
        $("#background-body").css('background-image','url("img/middle-font.png")');
      }else{
        $("#background-opacity").css('opacity', 1);
        $("#section-title").css('opacity', 1);
        $("#background-body").css('background-image',"none");
        $(".hero-move-two").css('opacity', 1);
        $(".hero-move-one").css('opacity', 1);
        $(".hero-move-three").css('opacity', 1);
        $(".hero-move-four").css('opacity', 1);
      }
      document.body.classList[
          window.scrollY > 100 ? 'add': 'remove'
      ]('scrolled');
    }, {
      capture: true,
      passive: true
    })
  
  }).call(this);


  $("#burger, nav ul li").on("click", function(){
    $("#header-wrapper").toggleClass("open");
    $("nav ul").toggleClass("open");
  });
  
  
  
  
  
  window.addEventListener('load', function () {
    document.body.classList[
        window.scrollY > 100 ? 'add': 'remove'
    ]('scrolled');
  });

  var leftOrRight = true;
  setInterval(() => {
    movement()
}, 5000);
movement()

function movement(){
  var slides = document.getElementsByClassName("balance-anim");
  for (var i = 0; i < slides.length; i++) {
      //if(/*randRang(1,10)<2 &&*/ window.scrollY < 600){
        var div = slides[i];
        div.style.webkitTransform = 'translate('+(leftOrRight?(div.dataset.translate+"vw"):("-"+div.dataset.translate+"vw"))+')'; 
        div.style.mozTransform    = 'translate('+(leftOrRight?(div.dataset.translate+"vw"):("-"+div.dataset.translate+"vw"))+')'; 
        div.style.msTransform     = 'translate('+(leftOrRight?(div.dataset.translate+"vw"):("-"+div.dataset.translate+"vw"))+')'; 
        div.style.oTransform      = 'translate('+(leftOrRight?(div.dataset.translate+"vw"):("-"+div.dataset.translate+"vw"))+')'; 
        div.style.transform       = 'translate('+(leftOrRight?(div.dataset.translate+"vw"):("-"+div.dataset.translate+"vw"))+')'; 
    
      //}
      leftOrRight = !leftOrRight;
  }
  leftOrRight = !leftOrRight;
}
  