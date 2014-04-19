(->
  # DomReady
  $ ->
    Ugomeku.setup($('#canvas')[0])
)()

((exports) ->
  'use strict'
  class Ugomeku
    @canvas: null
    @content: null
    @camera: null
    @windowHalfX: null
    @windowHalfY: null
    @renderer: null

    @setup = (canvas) ->
      @canvas = canvas

      scene = null
      materials = []
      mouseX = 0
      mouseY = 0
      @windowHalfX = $(window).width() / 2
      @windowHalfY = $(window).height() / 2

      width = $(window).width()
      height = $(window).height()

      @camera = new THREE.PerspectiveCamera(75, width / height, 1, 3000)
      @camera.position.z = 1000

      scene = new THREE.Scene()
      scene.fog = new THREE.FogExp2( 0xffffff, 0.00001 )

      directionalLight = new THREE.DirectionalLight(0x000000, 10)
      directionalLight.position.z = 0
      scene.add directionalLight

      geometry = new THREE.Geometry()

      sprite1 = THREE.ImageUtils.loadTexture('./images/thumb12.png')
      sprite2 = THREE.ImageUtils.loadTexture('./images/thumb1.jpg')
      sprite3 = THREE.ImageUtils.loadTexture('./images/thumb2.jpg')

      i = 0
      while i < 800
        vertex = new THREE.Vector3()
        vertex.x = Math.random() * 2000 - 1000
        vertex.y = Math.random() * 2000 - 1000
        vertex.z = Math.random() * 2000 - 1000
        geometry.vertices.push vertex
        i++

      parameters = [
        [ [1.0, 0.2, 0.5], sprite1, 300 ],
        [ [0.95, 0.1, 0.5], sprite2, 220 ],
        [ [0.90, 0.05, 0.5], sprite3, 160 ]
      ]

      i = 0
      while i < parameters.length
        color = parameters[i][0]
        sprite = parameters[i][1]
        size = parameters[i][2]
        materials[i] = new THREE.ParticleSystemMaterial(
          size: size
          color: 0xffffff
          map: sprite
          blending: THREE.AdditiveBlending
          depthTest: false
          transparent: true
        )
        materials[i].color.setHSL color[0], color[1], color[2]
        particles = new THREE.ParticleSystem(geometry, materials[i])
        particles.rotation.x = Math.random() * 6
        particles.rotation.y = Math.random() * 6
        particles.rotation.z = Math.random() * 6
        scene.add particles
        i++

      @renderer = new THREE.WebGLRenderer(canvas: @canvas, alpha: true, clearAlpha: 1)
      @renderer.setSize width, height
      @renderer.setClearColor(new THREE.Color(0x000000), 10)

      stats = new Stats()
      stats.domElement.style.position = "fixed"
      stats.domElement.style.top = "0px"
      document.body.appendChild stats.domElement

     # エフェクトをかける
#      effect = new THREE.AnaglyphEffect(@renderer)
#      effect.setSize width, height

      animate = =>
        render()
        requestAnimationFrame animate
        stats.update()

      render = =>
        time = Date.now() * 0.00005
        @camera.position.x += (mouseX - @camera.position.x) * 0.05
        @camera.position.y += (-mouseY - @camera.position.y) * 0.05
        @camera.lookAt scene.position
        i = 0
        while i < scene.children.length
          object = scene.children[i]
          object.rotation.y = time * ((if i < 4 then i + 1 else -(i + 1)))  if object instanceof THREE.ParticleSystem
          i++
        i = 0
        while i < materials.length
          color = parameters[i][0]
          h = (360 * (color[0] + time) % 360) / 360
          materials[i].color.setHSL h, color[1], color[2]
          i++
        @renderer.render scene, @camera

      animate()

      $(document).on 'mousemove', (event) =>
        mouseX = event.clientX - @windowHalfX
        mouseY = event.clientY - @windowHalfY
      @

    @resize = () =>
      @windowHalfX = $(window).width() / 2
      @windowHalfY = $(window).height() / 2
      @camera.aspect = $(window).width() / $(window).height()
      @camera.updateProjectionMatrix()
      @renderer.setSize $(window).width(), $(window).height()

  exports.Ugomeku = Ugomeku
) @
