app.directive("upload", ->
  # @todo legacy support
  unless window.File && window.FileReader && window.FileList && window.Blob
    alert "This browser does not support modern upload"

  noopHandler = (event)->
    event.stopPropagation()
    event.preventDefault()
    return false


  # when there is a `dragover` on any HTML tag's child element, add class 'dragover' to HTML tag
  # and remove the class when `drop` or `dragleave`
  # also noop all the event
  addDragoverClass = ->
    $html = angular.element document.getElementsByTagName 'html'
    timeoutId = null
    $html.bind 'dragleave drop', (event)->
      fn = -> $html.removeClass 'dragover'
      # due to 'bubbling', `dragleave` is triggered when mouse leaving a child tag and entering another child tag
      # to overcome this issue, set a timeout of 10ms
      timeoutId = setTimeout fn, 10
      noopHandler event
    $html.bind 'dragover', (event)->
      # clear timeout if any, because we no longer need to remove 'dragover' class
      clearTimeout timeoutId
      $html.addClass 'dragover'
      noopHandler event
  addDragoverClass()

  ###
  @callback [String] result the base64 data of resized image
  ###
  thumbnail = (base64, maxWidth = 150, maxHeight = 150, callback) ->

    # Create and initialize two canvas
    canvas = document.createElement("canvas")
    ctx = canvas.getContext("2d")
    canvasCopy = document.createElement("canvas")
    copyContext = canvasCopy.getContext("2d")

    # Create original image
    img = new Image()
    img.src = base64

    img.onload = ->
      # Determine new ratio based on max size
      ratio = 1
      if img.width > maxWidth
        ratio = maxWidth / img.width
      else if img.height > maxHeight
        ratio = maxHeight / img.height

      # Draw original image in second canvas
      canvasCopy.width = img.width
      canvasCopy.height = img.height
      copyContext.drawImage img, 0, 0

      # Copy and resize second canvas to first canvas
      canvas.width = img.width * ratio
      canvas.height = img.height * ratio
      ctx.drawImage canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvas.width, canvas.height
      callback(null, canvas.toDataURL())

  link = (scope, element, attrs, ngModel) ->
    # do nothing if no ng-model
    return unless ngModel

    ngModel.$render = ->
      if viewValue = ngModel.$viewValue
        img = element.find('img')[0]
        img.src = viewValue

    # Write data to the model
    setModel = (value)->
      scope.$apply(ngModel.$setViewValue(value))


    childElement = document.createElement('img')
    element.append(childElement)


    # on drag enter, add class hover
    element.bind 'dragenter', (event)->
      noopHandler event
      element.addClass('dragover')

    # on drag leave, remove class hover
    element.bind 'dragleave', dragleave = (event)->
      # need to bubble this event to parent
      #noopHandler event
      element.removeClass('dragover')

    # on dragover, noop
    #element.bind "dragover", noopHandler

    # on drop, noop (prevent default), remove class hover, process data
    element.bind "drop", (event)->
      # need to bubble this event to parent
      #noopHandler(event)
      dragleave(event)

      # 1. Get the DataTransfer object from the event
      # 2. Get the list of File objects that were dropped (via a FileList) from the DataTransfer object
      files = event.dataTransfer.files

      # @todo drag from URL
      ###
      ((event)->
        console.log event.dataTransfer.types[0], 'data transafer'
        console.log event.dataTransfer.getData('text/uri-list'), 'text/uri-list'
        console.log event.dataTransfer.getData('Files'), 'data transafer'

      )(event)
      ###
      count = files.length

      # If we have 1 or more files that were dropped, process them with the handleFiles function
      # Only call the handler if 1 or more files was dropped.
      if (count > 0)
        # Grab the first file from the FileList – we only use the first file dropped
        file = files[0]
        # Only process image files.
        unless file.type.match('image.*')
          return alert "no!"

        # Create a new FileReader (new File API) to read the file contents off disk
        reader = new FileReader()

        # Register an onload handler with the FileReader that will process the file after it’s read
        reader.onload = (event) ->
          #result = event.target.result
          thumbnail event.target.result, null, null, (err, result) ->
            childElement.src = result
            setModel(result)

        # begin the read operation
        # Start the read operation; reading files in as “data URL” formatted elements. We do this because we can literally set our return value as the <img> tag’s src attribute and see them render; it’s slick!
        reader.readAsDataURL(file)

  # Public API
  restrict: 'A' # only activate on element attribute
  require: '?ngModel' # get a hold of NgModelController
  #controller: controller
  link: link
)
