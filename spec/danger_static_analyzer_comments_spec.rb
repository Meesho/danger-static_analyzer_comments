require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerStaticAnalyzerComments do
    it 'should be a plugin' do
      expect(Danger::DangerStaticAnalyzerComments.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @static_analyzer_comments = @dangerfile.static_analyzer_comments
        allow(@static_analyzer_comments.git).to receive(:deleted_files).and_return([])
        allow(@static_analyzer_comments.git).to receive(:added_files).and_return([])
        allow(@static_analyzer_comments.git).to receive(:modified_files).and_return(
            [
                "/Users/gustavo/Developer/app-android/app/src/main/java/com/loadsmart/common/views/AvatarView.java",
                "/Users/gustavo/Developer/app-android/app/src/main/java/com/loadsmart/analytics/Events.java"
            ])
      end
    end
  end
end
