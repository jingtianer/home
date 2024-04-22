---
title: gallery
date: 2024-04-23 00:38:11
comments: true
photos: 
    - /images/flume-plugins-project.png
    - /images/structure.png
categories:
    - gallery
tags:
    - gallery
---

<head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/galleria/1.5.7/galleria.min.js"></script>
</head>
<style>
    .galleria{ 
        width: 100%; 
        height: 100vh; 
    }
</style>
<div class="galleria">
    <img src="/home/images/gallery/gallery9.jpeg">
    <img src="/home/images/gallery/gallery13.jpeg">
    <img src="/home/images/gallery/gallery14.jpeg">
    <img src="/home/images/gallery/gallery15.jpeg">
    <img src="/home/images/gallery/gallery16.jpeg">
    <img src="/home/images/gallery/gallery17.jpeg">
    <img src="/home/images/gallery/gallery18.jpeg">
    <img src="/home/images/gallery/gallery19.jpeg">
    <img src="/home/images/gallery/gallery20.jpeg">
    <img src="/home/images/gallery/gallery21.jpeg">
    <img src="/home/images/gallery/gallery8.jpeg">
    <img src="/home/images/gallery/gallery22.jpeg">
    <img src="/home/images/gallery/gallery24.jpeg">
    <img src="/home/images/gallery/gallery23.jpeg">
    <img src="/home/images/gallery/gallery27.jpeg">
    <img src="/home/images/gallery/gallery28.jpeg">
    <img src="/home/images/gallery/gallery29.jpeg">
    <img src="/home/images/gallery/gallery30.jpeg">
    <img src="/home/images/gallery/gallery12.jpeg">
    <img src="/home/images/gallery/gallery31.png">
    <img src="/home/images/gallery/gallery25.jpeg">
    <img src="/home/images/gallery/gallery26.jpeg">
    <img src="/home/images/gallery/gallery10.jpeg">
    <img src="/home/images/gallery/gallery11.jpeg">
    <img src="/home/images/gallery/gallery1.jpeg">
    <img src="/home/images/gallery/gallery2.jpeg">
    <img src="/home/images/gallery/gallery3.jpeg">
    <img src="/home/images/gallery/gallery4.jpeg">
    <img src="/home/images/gallery/gallery32.jpeg">
    <img src="/home/images/gallery/gallery5.jpeg">
    <img src="/home/images/gallery/gallery6.jpeg">
    <img src="/home/images/gallery/gallery7.jpeg">
</div>
<script>
(function() {
    Galleria.loadTheme('https://cdnjs.cloudflare.com/ajax/libs/galleria/1.5.7/themes/classic/galleria.classic.min.js');
    Galleria.run('.galleria', {
        extend: function() {
            var gallery = this; // "this" is the gallery instance
            $('.galleria').click(function() {
                console.log("click");
                gallery.playToggle(1000).toggleFullscreen(); // call the play method
            });
        }
    });
}());
</script>
