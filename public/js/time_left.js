function time_left() {

    $(".time").each(function(index, element) {
        var date=$(element).next().text();
    
        const diff = moment( date ).diff( moment() );
        
        // ミリ秒からdurationオブジェクトを生成
        const duration = moment.duration( diff );
        
        // 日・時・分・秒を取得
        const days    = Math.floor( duration.asDays() );
        const hours   = duration.hours();
        const minutes = duration.minutes();
        const seconds = duration.seconds();
        
        if(0<days){
            $(element).text(`${days}日と${hours}時間`);
        }else if(0!=hours){
            $(element).text(`${hours}時間${minutes}分${seconds}秒`);
        }else{
            $(element).text(`${minutes}分${seconds}秒`);
        }
        
        //console.log( `${index}:${days}日と${hours}時間${minutes}分${seconds}秒` );
    
  });

}setInterval('time_left()',1000);