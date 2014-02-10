namespace :data do
  desc "Fetch the lotto data from http://www.lecai.com/lottery/draw/list/1"
  task fetch: :environment do
    spider = MicroSpider.new
    spider.learn do
      site 'http://www.lecai.com'
      entrance_on_path '/lottery/draw/list/1', '.year_select option' do |element|
        "/lottery/draw/list/1?d=#{element.value}"
      end
      foreach '#draw_list tbody tr' do |element|
        tds  = element.all('td')
        date = tds[0].text
        lun  = tds[1].text
        tds[2].text.split.each do |number|
          Lottery.create!(
            lucky_date: Date.parse(date),
            lun: lun,
            number: number.to_i,
            full_number: tds[2].text
          )
        end
      end
    end
    spider.crawl
  end

  desc "Analysis! Comeon baby!!!"
  task analysis: :environment do

  end

end
