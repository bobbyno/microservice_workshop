require "bunny"
require "json"

require_relative 'rabbitmq_binding'
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_details'

# Streams rental-offer-related requests to the console
class JoinLoyaltyOffer
  include RabbitmqBinding

  private

    def process(channel, exchange)
      puts " [*] Waiting for needs on the '#{@bus_name}' bus... To exit press CTRL+C"
      queue(channel, exchange).subscribe(block: true) do |delivery_info, properties, body|
        process_packet body, exchange
      end
    end

    def process_packet body, exchange
      content = JSON.parse body
      return unless content['need'] == RentalOfferNeedPacket::NEED
      packet = JSON.load body
      return unless packet.unsatisfied?
      packet.propose_solution loyalty_solution(packet)
      exchange.publish packet.to_json
    rescue JSON::ParserError => _
      # Ignore: "This is not the message we are looking for..."
    end

    def loyalty_solution(packet)
      puts " [x] Proposed solution with creative 'join_us_1'"
      RentalOfferSolutionDetails.new(creative: 'join_us_1.jpg', value: 35, type: 'membership')
    end

end
