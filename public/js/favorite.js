$(function(){
	      $(".fa-star").click(function(){
			var like=$(this);
	        var jacket = $(this).next().text();//.val()はinput()内でしか入らない
	        var release = $(this).next().next().text();
	        var title = $(this).next().next().next().text();
	        

	        var request = $.ajax({
	          type: "POST",
	          url: "/new/favorite",
	          data: {
	            jacket: jacket,
	            release:  release,
	            title: title
	          }
	        });
	        request.done(function(){
	        $.ajax({
	            type: "GET",
	            url: "/favorite/post",
	            data: {
	            title: title
	            },
	            dataType: "json"
		        })
		        .done(function(res){
		        	if(res.num==1){
		        		like.attr('class', 'fas fa-star fa-2x');
		        	}else{
		        		like.attr('class', 'far fa-star fa-2x');
		        	}
          		});
	      	});
     });
});