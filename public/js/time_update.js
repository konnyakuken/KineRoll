$(function(){
  $(window).on('load', function() {
      
      
      
  });
});


function timeCheck2() {
    
    // diffメソッドを使って、現時刻と2017年7月1日の日時の差を、ミリ秒で取得
    var date_first=$('.date').first().text()
    //console.log(date_first);
    //console.log(moment());
    const diff = moment( date_first ).diff( moment() );
    
    // ミリ秒からdurationオブジェクトを生成
    const duration = moment.duration( diff );
    
    // 日・時・分・秒を取得
    const days    = Math.floor( duration.asDays() );
    const hours   = duration.hours();
    const minutes = duration.minutes();
    const seconds = duration.seconds();
    
    
    if( days<0 ){
                $.ajax({
                    type: "GET", // GETメソッドで通信
             
                    url: "/update/schedule", // 取得先のURL
             
                    cache: false, // キャッシュしないで読み込み
             
                    // 通信成功時に呼び出されるコールバック
                    success: function (data) {
                        $('#ajaxreload').html(data);
                    },
                    // 通信エラー時に呼び出されるコールバック
                    error: function () {
                        alert("Ajax通信エラー");

                    }
                });
    }
    /*
    if( days<0 ){
         var request = $.ajax({
	          type: "get",
	          url: "/update/schedule",
	        }).done(function(){
	        	$.ajax({
                    type: "GET", // GETメソッドで通信
             
                    url: "/update/erb", // 取得先のURL
             
                    cache: false, // キャッシュしないで読み込み
             
                    // 通信成功時に呼び出されるコールバック
                    success: function (data) {
                        $('#ajaxreload').html(data);
                    },
                    // 通信エラー時に呼び出されるコールバック
                    error: function () {
                        alert("Ajax通信エラー");

                    }
                });
          	});
    }*/
    // 出力
    //console.log( `${days}日と${hours}時間${minutes}分${seconds}秒` );
    
        }
        setInterval('timeCheck2()',1000);