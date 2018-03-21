<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<html>
  <head>
      <meta charset="UTF-8">
      <title>네이버 지도 API - 주소로 지도 표시하기</title>
      <script type="text/javascript" src="https://openapi.map.naver.com/openapi/v3/maps.js?clientId=lLWN_ojJYVj9L7235_lg&submodules=geocoder"></script>
  	  <script src="/resources/js/jquery-3.2.1.js" charset="utf-8"></script>
  </head>
  <body>
  <div>
  	<input id="address" type="text" placeholder="도로명주소 입력해주세요!">
  	<button id="submit" type="button">검색</button>
  </div>
    <div id="map" style="width:100%;height:400px;"></div>
    <script>
    var map = new naver.maps.Map("map", {
        center: new naver.maps.LatLng(37.3595316, 127.1052133),
        zoom: 10,
        mapTypeControl: true
    });

    var infoWindow = new naver.maps.InfoWindow({
        anchorSkew: true
    });

    map.setCursor('pointer');
    
    
    ////////////////////////////////////////////////////////////////////////// 마커 부분 시작
    
    
    var HOME_PATH = window.HOME_PATH || '.';
    
    var latlngs = [
        new naver.maps.LatLng(37.5256101, 127.0156204),
        new naver.maps.LatLng(37.5239302, 127.0192074),
        new naver.maps.LatLng(37.5276264, 127.017622)
       
    ];
    

    var markerList = [];

    for (var i=0, ii=latlngs.length; i<ii; i++) {
        var icon = {
                url: HOME_PATH +'/img/example/sp_pins_spot_v3.png',
                size: new naver.maps.Size(24, 37),
                anchor: new naver.maps.Point(12, 37),
                origin: new naver.maps.Point(i * 29, 0)
            },
            marker = new naver.maps.Marker({
                position: latlngs[i],
                map: map,
                icon: icon
            });

        marker.set('seq', i);

        markerList.push(marker);

        marker.addListener('mouseover', onMouseOver);
        marker.addListener('mouseout', onMouseOut);

        icon = null;
        marker = null;
    }
    
    function onMouseOver(e) {
        var marker = e.overlay,
            seq = marker.get('seq');
		//alert("마우스오버!");
    /*     marker.setIcon({
            url: HOME_PATH +'/img/example/sp_pins_spot_v3_over.png',
            size: new naver.maps.Size(24, 37),
            anchor: new naver.maps.Point(12, 37),
            origin: new naver.maps.Point(seq * 29, 50)
        }); */
		 infoWindow.setContent(["<a href='/index_1.jsp'>카카식당</a>" ].join('\n'));
	        infoWindow.open(map,marker);
    }

    function onMouseOut(e) {
        var marker = e.overlay,
            seq = marker.get('seq');
        //alert("마우스아웃!");
/*         marker.setIcon({
            url: HOME_PATH +'/img/example/sp_pins_spot_v3.png',
            size: new naver.maps.Size(24, 37),
            anchor: new naver.maps.Point(12, 37),
            origin: new naver.maps.Point(seq * 29, 0)
        }); */
        
        infoWindow.setContent(["<a href='/index_1.jsp'>다다식당</a>" ].join('\n'));
        infoWindow.open(map,marker);
    }
    
    ////////////////////////////////////////////////////////////////////////// 마커 부분 끝
    
    
    
    
    
    
   

    // search by tm128 coordinate
    function searchCoordinateToAddress(latlng) {
        var tm128 = naver.maps.TransCoord.fromLatLngToTM128(latlng);
		alert(latlng+"  ??");
        infoWindow.close();

        naver.maps.Service.reverseGeocode({
            location: tm128,
            coordType: naver.maps.Service.CoordType.TM128
        }, function(status, response) {
            if (status === naver.maps.Service.Status.ERROR) {
                return alert('Something Wrong!');
            }

            console.log(latlng);
            var items = response.result.items,
                htmlAddresses = [];

            for (var i=0, ii=items.length, item, addrType; i<ii; i++) {
                item = items[i];
                addrType = item.isRoadAddress ? '[도로명 주소]' : '[지번 주소]';

                htmlAddresses.push((i+1) +'. '+ addrType +' '+ item.address);
                htmlAddresses.push('&nbsp&nbsp&nbsp -> '+ latlng.x +','+ latlng.y);
            }

            infoWindow.setContent([
                    '<div style="padding:10px;min-width:200px;line-height:150%;">',
                    '<h4 style="margin-top:5px;">검색 좌표 : '+ response.result.userquery +'</h4><br />',
                    htmlAddresses.join('<br />'),
                    '</div>'
                ].join('\n'));

            infoWindow.open(map, latlng);
        });
    }

    // result by latlng coordinate
    function searchAddressToCoordinate(address) {
        naver.maps.Service.geocode({
            address: address
        }, function(status, response) {
            if (status === naver.maps.Service.Status.ERROR) {
                return alert('Something Wrong!');
            }

            var item = response.result.items[0],
                addrType = item.isRoadAddress ? '[도로명 주소]' : '[지번 주소]',
                point = new naver.maps.Point(item.point.x, item.point.y);

            infoWindow.setContent([
                    '<div style="padding:10px;min-width:200px;line-height:150%;">',
                    '<h4 style="margin-top:5px;">검색 주소 : '+ response.result.userquery +'</h4><br />',
                    addrType +' '+ item.address +'<br />',
                    '&nbsp&nbsp&nbsp -> '+ item.point.x +','+ item.point.y,
                    '</div>'
                ].join('\n'));


            map.setCenter(point);
            infoWindow.open(map, point);
        });
    }

    function initGeocoder() {
        map.addListener('click', function(e) {
            searchCoordinateToAddress(e.coord);
        });

        $('#address').on('keydown', function(e) {
            var keyCode = e.which;

            if (keyCode === 13) { // Enter Key
                searchAddressToCoordinate($('#address').val());
            }
        });

        $('#submit').on('click', function(e) {
            e.preventDefault();

            searchAddressToCoordinate($('#address').val());
        });

        searchAddressToCoordinate('강남대로');
    }

    naver.maps.onJSContentLoaded = initGeocoder;
      </script>
  </body>
</html>
  
  
  
  
  
  
  
  
  