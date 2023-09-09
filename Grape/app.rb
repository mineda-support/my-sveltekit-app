require 'grape'
$:.unshift File.join(ENV['HOME'].gsub(/\\/, '/'), '/work/alb2/lib')
$:.unshift '.'
puts "hello world from ruby"
# puts $:
require 'j_pack'

$work_dir = ENV['HOMEPATH'] + '/Seafile/PTS06_2022_8/BGR_TEG/'
$ckt_name = 'tsd_TEG_tb.asc'

module Test
  class API < Grape::API
    format :json
    prefix :api

    resource :blog do
      desc 'Return an article.'
      get :article do
        {
          "title" => "title",
          "body" => "body"
        }
      end
    end

    resource :ltspctl do
      desc 'Open LTspice'
      get :open do
        Dir.chdir($work_dir){
          ckt = LTspiceControl.new $ckt_name
          ckt.open
          {"ok" => "ok"}
        } 
        end
      desc 'Simulate'
      get :simulate do
        Dir.chdir($work_dir){
          ckt = LTspiceControl.new $ckt_name
          ckt.simulate
          {"end" => "end"}
        }
    end
    end
  end
end