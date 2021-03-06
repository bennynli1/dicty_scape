# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Annotation.delete_all;
Gene.delete_all;
GeneAnnotation.delete_all;
def getEvidenceCodeNum(string)
	result = nil;
    case string
        when "EXP"
    	result = 20;
        when "IDA"
    	result = 20;
        when "IPI"
    	result = 20;
        when "IMP"
    	result = 20;
        when "IGI"
    	result = 20;
        when "IEP"
    	result = 20;
        when "ISS"
    	result = 10;
        when "ISO"
    	result = 10;
        when "ISA"
    	result = 10;
        when "ISM"
    	result = 10;
        when "IGC"
    	result = 10;
        when "IBA"
    	result = 10;
        when "IBD"
    	result = 10;
        when "IKR"
    	result = 10;
        when "IRD"
    	result = 10;
        when "RCA"
    	result = 10;
        when "TAS"
    	result = 15;
        when "NAS"
   		result = 15;
        when "IC"
    	result = 15;
        when "ND"
    	result = 0;
        when "IEA"
    	result = 5;
        when "NR"
      	result = 0;		
        else
    	result = 0;
    end
    return result;
end
def getColorCode(string)
	result = nil;
    case string
        when "F"
        result = "#0000FF";
        when "P"
        result = "#00FF00";
        when "C"
        result = "#FF0000";
        else
        result = "#444";
    end
    return result;
end
data = [];
File.open("data.txt","r") do |f|
    f.read.split(/\r/).each do |tsv|
        data << tsv.split(/\t/);
    end
end
objects = [];
for i in 1...data.length do
    temp = Hash.new;
    for j in 0...data[0].length do
        temp.merge!(Hash[data[0][j] => data[i][j]]);
    end
    objects << temp;
end
annotation_objects = [];
File.open("data2.txt","r") do |f|
    f.read.split(/\n/).each do |line|
        if line == "[Typedef]"
            break;
        elsif line == "[Term]"
            temp = Hash.new;
        elsif line[0..2] == "id:"
            temp.merge!(Hash["go_id" => line[4..(line.length-1)]]);
        elsif line[0..4]=="name:"
            temp.merge!(Hash["annotation_name" => line[6..(line.length-1)]]);
            annotation_objects << temp;
        end
    end
end
relationships = [];
go_id = "";
File.open("data2.txt","r") do |f|
    f.read.split(/\n/).each do |line|
        if line == "[Typedef]"
            break;
        elsif line[0..2] == "id:"
            go_id = line[4..(line.length-1)];
        elsif go_id!=""&&line[0..4]=="is_a:"
            relationships <<
            {
                "go_id" => go_id,
                "parent_go_id" => line[6..15]
            }
        end
    end
end
genes = [];
annotations_temp = [];
gene_annotations = [];
objects.each do |i|
    genes <<
    {
        "db_object_id" => i["db_object_id"],
        "db_object_symbol" => i["db_object_symbol"],
        "db_object_name" => i["db_object_name"],
        "db_object_synonym" => i["db_object_synonym"],
    };
    annotations_temp << i["go_id"];
    if i["qualifier"]!="NOT"
        gene_annotations <<
        {
            "db_object_symbol" => i["db_object_symbol"],
            "go_id" => i["go_id"],
            "evidence_code" => i["evidence_code"],
            "aspect" => i["aspect"],
            "reference" => i["reference"],
            "aspect_num" => getEvidenceCodeNum(i["evidence_code"]),
            "color_code" => getColorCode(i["aspect"])
        };
    end
end
relationships.each do |i|
    annotations_temp << i["go_id"];
    annotations_temp << i["parent_go_id"];
end
puts "part 0 done"
annotations_temp = annotations_temp.uniq;
annotations = [];
annotation_objects.each do |i|
    if (annotations_temp.include?i["go_id"])
        annotations <<
        {
            "go_id" => i["go_id"],
            "annotation_name" => i["annotation_name"]
        }
    end
end
puts "part 1 done";
genes = genes.uniq;
annotations = annotations.uniq;
relationships = relationships.uniq;
puts genes.length
genes.each do |i|
    Gene.create!(
        db_object_id: i["db_object_id"],
        db_object_symbol: i["db_object_symbol"],
        db_object_name: i["db_object_name"],
        db_object_synonym: i["db_object_synonym"],
    );
end
puts "part 2 done";
puts annotations.length
annotations.each do |i|
    Annotation.create!(
        go_id: i["go_id"],
        annotation_name: i["annotation_name"]
    );
end
puts "part 3 done";
puts gene_annotations.length
gene_annotations.each do |i|
    GeneAnnotation.create!(
        db_object_symbol: i["db_object_symbol"],
        go_id: i["go_id"],
        evidence_code: i["evidence_code"],
        aspect: i["aspect"],
        reference: i["reference"],
        aspect_num: i["aspect_num"],
        color_code: i["color_code"]
    );
end
puts "part 4 done";
puts relationships.length
relationships.each do |i|
    Relationship.create!(
        go_id: i["go_id"],
        parent_go_id: i["parent_go_id"]
    );
end
puts "part 5 done";
