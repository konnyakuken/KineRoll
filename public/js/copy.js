$(function() {
  $('#js-copybtn').on('click', function(){
    // コピーする文章の取得
    let text = $('#js-copytext').text();
    // テキストエリアの作成
    let $textarea = $('<textarea></textarea>');
    // テキストエリアに文章を挿入
    $textarea.text(text);
    //　テキストエリアを挿入
    $(this).append($textarea);
    //　テキストエリアを選択
    $textarea.select();
    // コピー
    document.execCommand('copy');
    // テキストエリアの削除
    $textarea.remove();
    // アラート文の表示
    $('#js-copyalert').show().delay(2000).fadeOut(400);
  });
  
  
  $('#js-copyLine').on('click', function(){
    // コピーする文章の取得
    let text = "Line!"+$('#js-copytext').text();
    // テキストエリアの作成
    let $textarea = $('<textarea></textarea>');
    // テキストエリアに文章を挿入
    $textarea.text(text);
    //　テキストエリアを挿入
    $(this).append($textarea);
    //　テキストエリアを選択
    $textarea.select();
    // コピー
    document.execCommand('copy');
    // テキストエリアの削除
    $textarea.remove();
    $(".space").html('<p hidden class="space"></p>');
    
    // アラート文の表示
    $('#js-copyalert').show().delay(2000).fadeOut(400);
  });
  
});