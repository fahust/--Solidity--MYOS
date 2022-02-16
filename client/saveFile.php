<?php 
/*$filePath = dirname(__FILE__)."/img/generated/_metadata.json";
$metaData = file_get_contents($filePath);
$metaParsed = json_decode($metaData, true);
$metaNow = json_decode('{"name":"NYXIES #8","description":"Nyxies are mystical and tame creatures that can be reproduced ad infinitum","image":"https:\/\/tam.nyxiesnft.com\/img\/generated\/8.png","edition":0,"seller_fee_basis_points":250,"collection":{"name":"NYXIES","family":"EGGS"},"symbol":"NYXS","properties":{"files":[{"uri":"https:\/\/tam.nyxiesnft.com\/img\/generated\/8.png","type":"image\/png"}],"category":"image","creators":[{"address":"0x0cE1A376d6CC69a6F74f27E7B1D65171fcB69C80","share":100}]},"attributes":[{"trait_type":"egg","value":1},{"trait_type":"ears","value":"Common"},{"trait_type":"horn","value":"Rare"},{"trait_type":"mouth","value":"Rare"},{"trait_type":"eyes","value":"Curiosity"}]}');
foreach ($metaParsed as $key => $value) {
    if($value["name"]==$metaNow->name){
        $exist = true;
    }
}*/
saveBase64ImagePng($_POST["base64"],$_POST["folder"],$_POST["id"],$_POST["meta"],$_POST["allMeta"]);
function saveBase64ImagePng($base64Image, $imageDir,$id,$meta,$allMeta)
{
    //set name of the image file
    if (!file_exists(dirname(__FILE__)."/img/generated/".$id.".json")) {
    
        $filePath = dirname(__FILE__)."/img/generated/".$id.".json";
        file_put_contents($filePath, ($meta));
    }

    

        
    $filePath = dirname(__FILE__)."/img/generated/_metadata.json";
    $metaData = file_get_contents($filePath);
    $metaParsed = json_decode($metaData, true);
    $metaNow = json_decode($meta);
    $exist = false;
    foreach ($metaParsed as $key => $value) {
        if($value["name"]==$metaNow->name){
            $exist = true;
        }
    }
    if($exist == false)array_push($metaParsed,$metaNow);
    file_put_contents($filePath, json_encode($metaParsed));


    
    $fileName =  $id.'.png';

    $base64Image = trim($base64Image);
    $base64Image = str_replace('data:image/png;base64,', '', $base64Image);
    $base64Image = str_replace('data:image/jpg;base64,', '', $base64Image);
    $base64Image = str_replace('data:image/jpeg;base64,', '', $base64Image);
    $base64Image = str_replace('data:image/gif;base64,', '', $base64Image);
    $base64Image = str_replace(' ', '+', $base64Image);

    $imageData = base64_decode($base64Image);
    //Set image whole path here 
    $filePath = dirname(__FILE__)."/img/generated/"  . $fileName;
    file_put_contents($filePath, $imageData);

   echo json_encode('test');
   die();

}
?>