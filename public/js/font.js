    /* オプションは上から要素の最大幅、最小幅、フォントサイズの最大、最小、文字数 */
$(".title").flowtype({

    maxFont:  9999,
    minFont:   1,
    fontRatio:  $(".title").text().length
});
