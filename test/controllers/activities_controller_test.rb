require 'test_helper'

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user)
    @user_with_team = users(:user_with_team)
    @match = Match.last
  end

  test 'no logged user can not acces to new_activity path' do
    get new_match_activity_path(@match)
    assert_redirected_to new_user_session_path, 'Controller response unexpected'
    assert_equal flash[:alert], I18n.t('devise.failure.unauthenticated')
  end

  test 'logged user with team can access to new_activity path' do
    sign_in @user_with_team
    get new_match_activity_path(@match)
    assert_response :success
  end

  test 'loged user with team can create an activity' do
    team = teams(:team3)
    sign_in @user_with_team
    post match_activities_path(@match), params: { activity: { name: 'Android Studio',
                                                              description: 'prueba de Android',
                                                              pitch_audience: 'prueba de campos requeridos',
                                                              abstract_outline: 'prueba abstrac',
                                                              activity_type: 'Curso',
                                                              english: 0,
                                                              match_id: @match.id } }
    assert_redirected_to match_team_path(@match, team), 'Controller response unexpected'
    assert_equal flash[:notice], I18n.t('activities.messages.uploaded')
  end

  test 'no loged user can not create an activity' do
    post match_activities_path(@match), params: { activity: { id: 2,
                                                              name: 'Android Studio',
                                                              activity_type: 'Curso',
                                                              english: 0 } }
    assert_redirected_to new_user_session_path, 'Controller response unexpected'
    assert_equal flash[:alert], I18n.t('devise.failure.unauthenticated')
  end

  test 'users with no team can not access create activity view' do
    sign_in @user
    get new_match_activity_path(@match)
    assert_redirected_to new_match_team_path(@match), 'Controller response unexpected'
  end

  test 'users can not created an activity if the activity name is blank' do
    sign_in @user_with_team
    post match_activities_path(@match), params: { activity: { id: 3,
                                                              name: '',
                                                              activity_type: 'Curso',
                                                              english: 0 } }
    assert_response :success
    assert_equal flash[:alert], I18n.t('activities.messages.error_creating')
  end

  test 'user with no team is redirected to create team path' do
    sign_in @user
    get new_match_activity_path(@match)
    assert_redirected_to new_match_team_path
  end
end
