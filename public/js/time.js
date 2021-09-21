function showClock1() {
           var nowTime = new Date();
           var nowHour = nowTime.getHours();
           var nowMin  = nowTime.getMinutes();
           var nowSec  = nowTime.getSeconds();
           var msg = nowHour + "時" + nowMin + "分" + nowSec +"秒";
           document.getElementById("RealtimeClockArea").innerHTML = msg;
        }
        setInterval('showClock1()',1000);