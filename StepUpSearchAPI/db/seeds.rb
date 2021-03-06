require 'open-uri'

BASE_URL = "https://therapists.psychologytoday.com/rms/prof_results.php?sid=1499561046.1827_32152&city=San+Francisco&state=CA&rec_next="
API_URL = "https://ptscrapeapi.herokuapp.com//?url="

def extract_therapist_urls(url)
  page = Nokogiri::HTML(open(url))
  sleep(3)
  page.css('.result-name').each{|div| @therapist_urls << div["href"]}
end

def query_api(url)
  HTTParty.get(API_URL+url)
end

# generate a list of urls to grab profiles from
@therapist_urls = []
# list_urls = (1..1861).step(20).map{|num| BASE_URL + (num.to_s)}
list_urls = (1..21).step(20).map{|num| BASE_URL + (num.to_s)}
list_urls.each{|url|extract_therapist_urls(url)}
@count = 0

#Query API and generate therapists
@therapist_urls.each do |url|
  p url
  begin
  long_response = query_api(url)
  if long_response["data"] != "invalid search criteria"
    response = long_response["data"]
    therapist = Therapist.new
    therapist.pt_id = response["pt_id"]
    therapist.name = response["name"]
    p therapist.name
    therapist.title = response["title"]
    therapist.phone = response["phone"]
    therapist.street_address = response["street_address"]
    therapist.locality = response["locality"]
    therapist.state = response["state"]
    therapist.zipcode = response["zipcode"]
    therapist.blurb = response["blurb"]
    therapist.yrs_practice = response["yrs_practice"]
    therapist.school = response["school"]
    therapist.yr_graduated = response["yr_graduated"]
    therapist.license_no = response["license_no"]
    therapist.license_state = response["license_state"]
    # therapist.client_ethnicities = response["client_ethnicities"]
    # therapist.client_languages = response["client_languages"]
    therapist.client_ages = response["client_ages"]
    # therapist.client_categories = response["client_categories"]
    therapist.treatment_modalities = response["treatment_modalities"]
    therapist.treatment_orientation = response["treatment_orientation"]
    # therapist.target_issues = response["target_issues"]
    # therapist.issues = response["issues"]
    therapist.avg_cost = response["avg_cost"]
    therapist.sliding_scale = response["sliding_scale"]
    therapist.takes_insurance = response["takes_insurance"]
    therapist.accepted_insurance = response["accepted_insurance"]
    therapist.accepted_payments = response["accepted_payments"]
    therapist.save
    #create a therapist

    #create many to many relationship
    if response["client_ethnicities"] != "none provided"
      response["client_ethnicities"].each do |ethnicity|
        ce_object = ClientEthnicity.find_or_create_by(name: ethnicity)
        TherapistClientEthnicity.create(therapist_id: therapist.id, client_ethnicity_id: ce_object.id)
      end
    end

    if response["client_languages"] != "none provided"
      response["client_languages"].each do |language|
        l_object = ClientLanguage.find_or_create_by(name: language)
        TherapistClientLanguage.create(therapist_id: therapist.id, client_language_id: l_object.id)
      end
    end

    if response["client_categories"] != "none provided"
      response["client_categories"].each do |category|
        cc_object = ClientCategory.find_or_create_by(name: category)
        TherapistClientCategory.create(therapist_id: therapist.id, client_category_id: cc_object.id)
      end
    end

    if response["target_issues"] != "none provided"
      response["target_issues"].each do |issue|
        ti_object = TargetIssue.find_or_create_by(name: issue)
        TherapistTargetIssue.create(therapist_id: therapist.id, target_issue_id: ti_object.id)
      end
    end

    if response["issues"] != "none provided"
      response["issues"].each do |issue|
        i_object = Issue.find_or_create_by(name: issue)
        TherapistIssue.create(therapist_id: therapist.id, issue_id: i_object.id)
      end
    end

  end
  rescue 
  end
  @count += 1
  p "SEEDING NUMBER: #{@count}"
end

  #CREATE MDOELS FOR EACH OF THE API CALLS

# end

# long_response = {
#     "data": {
#         "pt_id": "50850",
#         "name": "Kimberly Pratt",
#         "title": "Clinical Social Work/Therapist, MSW, LCSW",
#         "phone": "(510) 423-3926",
#         "street_address": "55 New Montgomery Street",
#         "locality": "San Francisco",
#         "state": "California",
#         "zipcode": "94105",
#         "blurb": "Difficulties in life provide tremendous opportunities for growth and healing. Rather than viewing symptoms, distressing emotions, etc. simply as \"problems,\" I see these as the pathway toward greater personal growth and freedom. I use a variety of methods and techniques to help clients achieve their goals, emphasizing cognitive-behavioral and mindfulness-based therapy techniques, as these have proven to be effective in both my practice and formal research studies. This approach often leads to greater psychological well-being, more connection to others and an increased ability to \u0093live in the present.\u0094 I have experience helping clients with a variety of specific issues, including: stress reduction, anxiety/fears, depression, grief and loss, relationship problems, coping with illness, trauma, problems with low self- esteem and LGBT issues. I strive to create a safe, respectful and non-judgmental environment for clients to explore and express themselves. I work collaboratively and integrate mind, body and socio-cultural factors into my work when relevant. I also have experience as an elite athlete and coach, for those interested in peak mental performance in athletics. Feel free to contact me for a free, face-to-face consultation. Thank you for your interest in my services.",
#         "yrs_practice": 10,
#         "school": "University of California, Berkeley",
#         "yr_graduated": 2004,
#         "license_no": "27356",
#         "license_state": "California",
#         "client_ethnicities": "none provided",
#         "client_languages": "none provided",
#         "client_ages": [
#             "Adults",
#             "Elders (65+)"
#         ],
#         "client_categories": "none provided",
#         "treatment_modalities": [
#             "Individuals",
#             "Family"
#         ],
#         "treatment_orientation": [
#             "Coaching",
#             "Cognitive Behavioral (CBT)",
#             "Culturally Sensitive",
#             "Humanistic",
#             "Mindfulness-based (MBCT)",
#             "Positive Psychology",
#             "Relational",
#             "Somatic",
#             "Strength Based"
#         ],
#         "target_issues": [
#             "Depression",
#             "Anxiety",
#             "Self Esteem"
#         ],
#         "issues": [
#             "Depression",
#             "Anxiety",
#             "Self Esteem",
#             "Addiction",
#             "Anger Management",
#             "Behavioral Issues",
#             "Coping Skills",
#             "Emotional Disturbance",
#             "Family Conflict",
#             "Grief",
#             "Life Coaching",
#             "Peer Relationships",
#             "Relationship Issues",
#             "Spirituality",
#             "Sports Performance",
#             "Stress",
#             "Stress Management",
#             "Substance Abuse",
#             "Transgender",
#             "Trauma and PTSD",
#             "Women's Issues",
#             "Elderly Persons Disorders",
#             "Mood Disorders",
#             "Bisexual",
#             "Gay",
#             "Lesbian"
#         ],
#         "avg_cost": "$120 - $140",
#         "sliding_scale": "Yes",
#         "takes_insurance": "Yes",
#         "accepted_insurance": [
#             "Medicare",
#             "Out of Network"
#         ],
#         "accepted_payments": [
#             "Cash",
#             "Check",
#             "Health Savings Account",
#             "Paypal"
#         ]
#     }
# }

# response = long_response[:data]

# therapist = Therapist.new
#     therapist.pt_id = response["pt_id)
#     therapist.name = response["name)
#     therapist.title = response["title)
#     therapist.phone = response["phone)
#     therapist.street_address = response["street_address)
#     therapist.locality = response["locality)
#     therapist.state = response["state)
#     therapist.zipcode = response["zipcode)
#     therapist.blurb = response["blurb)
#     therapist.yrs_practice = response["yrs_practice)
#     therapist.school = response["school)
#     therapist.yr_graduated = response["yr_graduated)
#     therapist.license_no = response["license_no)
#     therapist.license_state = response["license_state)
#     # therapist.client_ethnicities = response["client_ethnicities)
#     # therapist.client_languages = response["client_languages)
#     therapist.client_ages = response["client_ages)
#     # therapist.client_categories = response["client_categories)
#     therapist.treatment_modalities = response["treatment_modalities)
#     therapist.treatment_orientation = response["treatment_orientation)
#     # therapist.target_issues = response["target_issues)
#     # therapist.issues = response["issues)
#     therapist.avg_cost = response["avg_cost)
#     therapist.sliding_scale = response["sliding_scale)
#     therapist.takes_insurance = response["takes_insurance)
#     therapist.accepted_insurance = response["accepted_insurance)
#     therapist.accepted_payments = response["accepted_payments)
#     therapist.save
#     #create a therapist

#     #create many to many relationship
#     if response[:client_ethnicities] != "none provided"
#       response[:client_ethnicities].each do |ethnicity|
#         ce_object = ClientEthnicity.find_or_create_by(name: ethnicity)
#         TherapistClientEthnicity.create(therapist_id: therapist.id, client_ethnicity_id: ce_object.id)
#       end
#     end

#     if response[:client_languages] != "none provided"
#       response[:client_languages].each do |language|
#         l_object = ClientLanguage.find_or_create_by(name: language)
#         TherapistClientLanguage.create(therapist_id: therapist.id, client_language_id: l_object.id)
#       end
#     end

#     if response[:client_categories] != "none provided"
#       response[:client_categories].each do |category|
#         cc_object = ClientCategory.find_or_create_by(name: category)
#         TherapistClientCategory.create(therapist_id: therapist.id, client_category_id: cc_object.id)
#       end
#     end

#     if response[:target_issues] != "none provided"
#       response[:target_issues].each do |issue|
#         ti_object = TargetIssue.find_or_create_by(name: issue)
#         TherapistTargetIssue.create(therapist_id: therapist.id, target_issue_id: ti_object.id)
#       end
#     end

#     if response[:issues] != "none provided"
#       response[:issues].each do |issue|
#         i_object = Issue.find_or_create_by(name: issue)
#         TherapistIssue.create(therapist_id: therapist.id, issue_id: i_object.id)
#       end
#     end
