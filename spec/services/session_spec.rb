# frozen_string_literal: true

require 'spec_helper'

describe Mobile::Session do
  it 'connects to redis only when data needs to be read or saved' do
    expect_any_instance_of(Redis).not_to receive(:get)
    expect_any_instance_of(Redis).not_to receive(:set)

    session = described_class.new(session_key: 'skey')
    session.save
  end

  it 'reads from redis' do
    expect_any_instance_of(Redis).to receive(:get)

    session = described_class.new(session_key: 'skey')
    expect(session[:served_ads]).to be_nil
  end

  it 'saves a setting to session' do
    expect_any_instance_of(Redis).to receive(:get)
    expect_any_instance_of(Redis).to receive(:set)

    session = described_class.new(session_key: 'skey')
    served_ads = session[:served_ads]
    expect(served_ads).to be_nil
    session[:served_ads] = [100, 101]
    session.save
  end

  it 'fetches existing values, updates and stores it back in session_key' do
    session = described_class.new(session_key: 'skey')
    session[:served_ads] = [1, 2, 3]
    session[:last_visit] = '2/11/2022'
    session.save

    session = described_class.new(session_key: 'skey')
    expect(session[:last_visit]).to eq('2/11/2022')
    served_ads = session[:served_ads]
    served_ads << 4
    served_ads << 5
    session.save

    session = described_class.new(session_key: 'skey')
    expect(session[:served_ads]).to eq([1, 2, 3, 4, 5])
  end

  it 'verifies session_key expires in 1 week' do
    session = described_class.new(session_key: 'skey')
    session[:served_ads] = [100, 200]
    session.save

    Timecop.freeze(Time.current + 604_799.seconds) do
      session = described_class.new(session_key: 'skey')
      expect(session[:served_ads]).to eq [100, 200]
    end

    Timecop.freeze(Time.current + 604_800.seconds) do
      session = described_class.new(session_key: 'skey')
      expect(session[:served_ads]).to eq nil
    end
  end
end
