class QueryController < ApplicationController
  def index
    @queries = Queries
  end

  def examples
    @queries = Queries.map do |q|
      params[q[:input][:name]] = q[:input][:example]

      result = q.dup

      begin
        result[:result] = eval(q[:query]).inspect
      rescue => e
        result[:sql] = last_sql
        result[:result] = e
      end

      params[q[:input][:name]] = nil

      result[:sql] = last_sql
      result
    end
  end

  Queries.each do |query|
    class_eval <<-RUBY
      def #{query[:action]}
        begin
          show #{query[:query]}
        rescue => e
          @error = e
          @sql = last_sql
          render :partial => 'error'
        end
      end
    RUBY
  end

  private

  def show query
    @sql = last_sql
    render :partial => 'result', :locals => { :query => query }
  end

  def last_sql
    sql = $last_sql
    $last_sql = nil
    sql
  end
end
