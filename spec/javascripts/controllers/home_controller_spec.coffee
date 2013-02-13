describe 'ActionmanApp', ()->

  describe 'HomeCtrl', () -> 
    ideas = [{ body: 'Body language affects how others see us, but it may also change how we see ourselves.'}]
    actions = [{ description: 'Body language affects how others see us, but it may also change how we see ourselves.'}]
    counts = { members: 5, ideas: 6, actions_taken: 7 }

    scope = null
    ctrl = null
    $httpBackend = null

    beforeEach inject (_$httpBackend_, $rootScope, $controller) ->
      $httpBackend = _$httpBackend_
      $httpBackend.expectGET("#{window.ENDPOINT}/counts.json").respond(counts)
      $httpBackend.expectGET("#{window.ENDPOINT}/ideas/recent.json").respond(ideas)
      $httpBackend.expectGET("#{window.ENDPOINT}/actions/recent.json").respond(actions)
      scope = $rootScope.$new()
      ctrl = $controller( 'HomeCtrl', { $scope: scope, $routeParams: { } })

    it 'should set the ideas correctly', () ->
      expect(scope.ideas).toBeUndefined()
      $httpBackend.flush()
      expect(scope.ideas).toEqual(ideas);

    it 'should set the actions correctly', () ->
      expect(scope.actions).toBeUndefined()
      $httpBackend.flush()
      expect(scope.actions).toEqual(actions);

    it 'should set the counts correctly', () ->
      expect(scope.counts).toBeUndefined()
      $httpBackend.flush()
      expect(scope.counts).toEqual(counts);