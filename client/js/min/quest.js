/**
 * QUEST
 */

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
        getAllItems();
    }, 500);
    }
}

function renderQuest(data){
    return "<div class='card col-3'><strong class='card-header'>#"+data.id+"</strong><div class='quest-"+data.id+"'>"
    +"<div class='card-body'>"
    +"<div>Success : "+data.percentDifficulty+" %</div>"
    +"<div>Seconds to finish : "+data.time+"</div>"
    +"<div>Valid : "+data.valid+"</div>"
    +requirementStats(data)
    +selectHero()
    +startOrCompleteRender(data)
    +'</div>'
    +'</div>'
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
    console.log(questId)
    console.log($(".quest-"+questId+" select").val())
    await contract.methods.startQuest($(".quest-"+questId+" select").val(),(questId)).send({
        from: ethereum.selectedAddress,
    }).catch((error)=>{console.log('error transfer',error)}).then(()=>{
        startMain()
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
        startMain()
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
        startMain()
    });
    }
}