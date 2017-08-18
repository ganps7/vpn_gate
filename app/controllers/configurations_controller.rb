class ConfigurationsController < ApplicationController
    def show
        if not logged_in?
            redirect_to '/'
            return
        end
        @gate_url = 'https://localhost'
        @gate_token = 'default_token'
        @min_user_id = '5000'
        @pre_shared_key = 'default_pre_shared_key'
        pam_config = File.read('/etc/pam.d/gate-sso')
        pam_config.split(' ').each do |data|
            if data.include? 'url='
                @gate_url = data[4..-1]
            elsif data.include? 'token='
                @gate_token = data[6..-1]
            elsif data.include? 'min_user_id='
                @min_user_id = data[12..-1]
            end
        end
        ipsec_secrets = File.read('/etc/ipsec.secrets')
        ipsec_secrets.split("\n").each do |line|
            if line.include? 'PSK'
                @pre_shared_key = line.split(' ')[-1]
            end
        end
    end
    def update
        if not logged_in?
            redirect_to '/'
            return
        end
        @gate_url = 'https://localhost'
        @gate_token = 'default_token'
        @min_user_id = '5000'
        @pre_shared_key = 'default_pre_shared_key'

        if params[:configuration][:gate_url]
            @gate_url = params[:configuration][:gate_url]
        end
        if params[:configuration][:gate_token]
           @gate_token = params[:configuration][:gate_token]
        end
        if params[:configuration][:min_user_id]
            @min_user_id = params[:configuration][:min_user_id]
        end
        if params[:configuration][:pre_shared_key]
            @pre_shared_key = params[:configuration][:pre_shared_key]
        end
        gate_sso = ERB.new(File.read('app/views/configurations/gate-sso.erb'))
        ipsec_secrets = ERB.new(File.read('app/views/configurations/ipsec.secrets.erb'))
        File.write('/etc/pam.d/gate-sso', gate_sso.result(binding))
        File.write('/etc/ipsec.secrets', ipsec_secrets.result(binding))

        `ipsec rereadsecrets`

        redirect_to '/configuration'
    end
end