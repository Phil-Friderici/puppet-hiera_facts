require 'spec_helper'

describe 'hiera_facts::usecases' do
  let(:pre_condition) do
    <<-'ENDofPUPPETcode'
      class hiera_facts::usecases (
        Stdlib::Absolutepath  $path    = '/default.value',
        Variant[String,Array] $content = 'default content',
      ) {

        case $content {
          Array:   { $content_string = join($content, ",") }
          default: { $content_string = $content }
        }

        file { 'dummy':
          path    => $path,
          content => $content_string,
        }
      }
      include ::hiera_facts::usecases
    ENDofPUPPETcode
  end

  describe 'with profile_fact and team_fact not set' do
    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/default.value',
        'content' => 'default content',
      )
    end
  end

  describe 'with profile_fact and team_fact set to non existing hiera data' do
    let :facts do
      {
        profile_fact: 'does_not_exist',
        team_fact:    'does_not_exist',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/default.value',
        'content' => 'default content',
      )
    end
  end

  describe 'with profile_fact => strings' do
    let :facts do
      {
        profile_fact: 'strings',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/profile-strings',
        'content' => 'profile-strings',
      )
    end
  end

  describe 'with team_fact => strings when team => team1' do
    let :facts do
      {
        team_fact: 'strings',
        team:      'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/team1-strings',
        'content' => 'team1-strings',
      )
    end
  end

  describe 'with team_fact => strings when team => team2' do
    let :facts do
      {
        team_fact: 'strings',
        team:      'team2',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/team2-strings',
        'content' => 'team2-strings',
      )
    end
  end

  describe 'with profile_fact => strings and team_fact => strings when team => team1' do
    let :facts do
      {
        profile_fact: 'strings',
        team_fact:    'strings',
        team:         'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/team1-strings',
        'content' => 'team1-strings',
      )
    end
  end

  describe 'with profile_fact => strings,strings-duplicate' do
    let :facts do
      {
        profile_fact: 'strings,strings-duplicate',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/profile-strings-duplicate',
        'content' => 'profile-strings-duplicate',
      )
    end
  end

  describe 'with profile_fact => strings,strings-duplicate and team_fact => strings when team => team1' do
    let :facts do
      {
        profile_fact: 'strings,strings-duplicate',
        team_fact:    'strings',
        team:         'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/team1-strings',
        'content' => 'team1-strings',
      )
    end
  end

  describe 'with profile_fact => array' do
    let :facts do
      {
        profile_fact: 'array',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/default.value',
        'content' => 'profile-array_element1,profile-array_element2',
      )
    end
  end

  describe 'with profile_fact => array and team_fact => array when team => team1' do
    let :facts do
      {
        profile_fact: 'array',
        team_fact:    'array',
        team:         'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/default.value',
        'content' => 'profile-array_element1,profile-array_element2,team1-array_element1,team1-array_element2',
      )
    end
  end

  describe 'with profile_fact => array,strings-duplicate and team_fact => array when team => team1' do
    let :facts do
      {
        profile_fact: 'array,strings-duplicate',
        team_fact:    'array',
        team:         'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/profile-strings-duplicate',
        'content' => 'team1-array_element1,team1-array_element2',
      )
    end
  end

  describe 'with profile_fact => strings-duplicate,array and team_fact => array when team => team1' do
    let :facts do
      {
        profile_fact:  'strings,array',
        team_fact:     'array',
        team:          'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/profile-strings',
        'content' => 'profile-array_element1,profile-array_element2,team1-array_element1,team1-array_element2',
      )
    end
  end

  describe 'with profile_fact => array,array-duplicate and team_fact => array when team => team1' do
    let :facts do
      {
        profile_fact:  'array,array-duplicate',
        team_fact:     'array',
        team:          'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/profile-array-duplicate',
        'content' => 'profile-array_element1,profile-array_element2,profile-array-duplicate_element1,profile-array-duplicate_element2,team1-array_element1,team1-array_element2',
      )
    end
  end

  describe 'with profile_fact => array,array-duplicate and team_fact => strings when team => team1' do
    let :facts do
      {
        profile_fact:  'array,array-duplicate',
        team_fact:     'strings',
        team:          'team1',
      }
    end

    it do
      is_expected.to contain_file('dummy').with(
        'path'    => '/team1-strings',
        'content' => 'team1-strings',
      )
    end
  end
end
