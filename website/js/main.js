var button_enable = true;

$(document).ready(function(){
    $("#progressbarTWInput").change(function(){
            readURL(this);
    });
});

function readURL(input){
    if(input.files && input.files[0]){
        var reader = new FileReader();
        reader.onload = function (e) {
            $("#preview_progressbarTW_img").attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
}

function JSON_to_Android(){
    window.location = 'json:{"中文欄位":"test","123":456}';
}

function callJS(value){
    let json = JSON.parse(value);
    
    switch (json.kind) {
        case 'check_network':
            if(json.data){
                alert("網路已接通");
            }else{
                alert("網路已斷線");
            }
            break;
        case 'access_privilege':
            console.debug(json.status);
            if(json.data){
                if(json.data.camera===true){
                    $("#camera_privileges_text").html("已取得");
                }else{
                    $("#camera_privileges_text").html("未取得");
                }
                if(json.data.location===true){
                    $("#location_privileges_text").html("已取得");
                }else{
                    $("#location_privileges_text").html("未取得");
                }
                if(json.data.storage===true){
                    $("#storage_privileges_text").html("已取得");
                }else{
                    $("#storage_privileges_text").html("未取得");
                }
            }
            break;  
        case 'server_api':
            console.debug(json.status);
            if(json.data){
                if(json.data.type === "post"){
                    $('#phone_post_text').val(JSON.stringify(json.data));
                }else if(json.data.type === "get"){
                    $('#phone_get_text').val(JSON.stringify(json.data));
                }
            }
            break;      
        case 'sqlite_setup':
            console.debug(json.status);
            if(json.data){
                $("#sqlite_table").empty();
                $.each( json.data, function( key, value ) {
                    $('#sqlite_table').append('<tr><td style="width:70%;text-align:left;">'+JSON.stringify(value.data)+'</td><td style="width:30%"><button class="item" style="padding:10px 10px;" onclick="delete_sqlite('+value.id+');">刪除資料</button></td></tr>');
                });
            }
            break;    
        case 'background_processing':
            console.debug(json.status);
            if(json.data === true){
                button_enable = true;
                $('#background_button').html("上傳資料");
            }else if(json.data){
                button_enable = false;
                $('#background_button').html("資料上傳中("+json.data+")");
            }
            break;      
        case 'get_location':
            console.debug(json.status);
            if(json.data){
                $('#location_table').append('<tr><td>緯度：'+json.data.longitude+'<br/>經度：'+json.data.latitude+'<br/>取得時間：'+json.data.datatime+'</td></tr>');
            }
            break;       
        case 'scan_qrcode':
            console.debug(json.status);
            if(json.data){
                $('#scan_result').html(json.data)
            }
            break;
        case 'show_qrcode':
            console.debug(json.status);
            break;   
        default:
            console.debug('ERROR');
    }
}
