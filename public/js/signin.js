$('.signin').on('click', function() {
    $.ajax({
        type: "GET", // GETメソッドで通信
 
        url: "/signin", // 取得先のURL
 
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