describe 'ActionmanApp', ()->

  describe 'ReactionCtrl', () -> 

    scope = null
    ctrl = null
    $httpBackend = null

    beforeEach inject (_$httpBackend_, $rootScope, $controller) ->
      ideaId = 1
      element = $('<div></div>')

      $httpBackend = _$httpBackend_

      window.ENDPOINT = 'window_endpoint'

      $httpBackend.expectPOST("#{window.ENDPOINT}/ideas/#{ideaId}/react.json", {text: 'my reaction'}).respond({})

      scope = $rootScope.$new()
      ctrl = $controller( 'ReactionCtrl', { $scope: scope, $element: element })

    it 'should create a react function', () ->
      expect(scope.react).toBeDefined()