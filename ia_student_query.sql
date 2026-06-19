select*
from ai_student;

select avg(weekly_genai_hours)
from ai_student;
#les étudiants utilisent en moyenne 8h30 l'ia

select year_of_study, avg(weekly_genai_hours)
from ai_student
group by year_of_study	
order by avg(weekly_genai_hours)
;

#les junior semble moins utilisé l'IA, les sénior utilisent le plus

select major_category, avg(weekly_genai_hours) as avg_weekly_genai_hours, avg(traditional_study_hours) as avg_study_hours
from ai_student
group by major_category
order by avg(weekly_genai_hours)
;

#plus grande disparité entre les sujets d'études. les STEM et Business utilisent beaucoup plus l'IA, et on peut émettre l'hypothèse d'une corrélation entre l'utilisation d'une IA et le temps d'étude, car plus on utilise moins on étudie (l'IA est-il un gain de temps?)

#est ce que ceux qui l'utilisent le plus sont bons en IA?

select weekly_genai_hours, prompt_engineering_skill
from ai_student
order by weekly_genai_hours desc
limit 20;

# dans les 20 premiers il y a une forte disparité aussi bien des débutants que des gens bons

select prompt_engineering_skill, avg(weekly_genai_hours) as avg_weekly_genai_hours
from ai_student
group by prompt_engineering_skill
order by prompt_engineering_skill
;
#ceux qui sont meilleurs semblent l'utiliser plus que les autres

#est ce que tout ça se vérifie dans les notes


select
    prompt_engineering_skill,
    avg((post_semester_gpa + pre_semester_gpa) / 2.0) as moyenne_skill
from ai_student
group by prompt_engineering_skill
order by moyenne_skill DESC;

# ceux qui maitrisent l'IA ont l'air d'avoir des meilleurs notes, mais pour vérifier si c'est corrélé il faut envisager le temps d'étude

select
    prompt_engineering_skill,
    avg((post_semester_gpa + pre_semester_gpa) / 2.0) as moyenne_skill, avg(traditional_study_hours) 
from ai_student
group by prompt_engineering_skill
order by moyenne_skill DESC;

# les personnes bonnes en IA travaillent moins et ont des meilleurs notes
# cela se vérifie-t-il en fonction des différentes catégories d'études?

select 
major_category, 
sum(case when prompt_engineering_skill = 'advanced' then 1 else 0 end) as nbr_advanced,
sum(case when prompt_engineering_skill = 'intermediate' then 1 else 0 end) as nbr_intermediate,
sum(case when prompt_engineering_skill = 'beginner' then 1 else 0 end) as nbr_beginner,
count(*) AS nbr_students
from ai_student
group by major_category
order by nbr_advanced desc; 

#on a calculé le nombre de personne pour chaque group, maintenant il faut faire le ratio pour avoir vraiment une idée

select major_category, nbr_advanced/nbr_students as ratio_advanced, nbr_intermediate/nbr_students as ratio_intermediate, nbr_beginner/nbr_students as ratio_beginner,avg_genai_hours
from (
select 
major_category, avg(weekly_genai_hours) as avg_genai_hours,
sum(case when prompt_engineering_skill = 'advanced' then 1 else 0 end) as nbr_advanced,
sum(case when prompt_engineering_skill = 'intermediate' then 1 else 0 end) as nbr_intermediate,
sum(case when prompt_engineering_skill = 'beginner' then 1 else 0 end) as nbr_beginner,
count(*) AS nbr_students
from ai_student
group by major_category) as count_skill
order by ratio_advanced desc
;

#les stem ont le plus de personnes compétentes en matière d'IA que le reste, et l'utilisent beaucoup plus. Les business ne sont pas compétent mais l'utilisent beaucoup


select
 major_category,
    avg((post_semester_gpa + pre_semester_gpa) / 2.0) as moyenne_general
from ai_student
group by major_category
order by moyenne_general DESC;

#difficile de comparer des catégories entre elles mais on remarque que pour les STEM qui sont ceux qui maitrise bien l'ia de manière générale ont les meilleurs moyennes

#ce qui serait intéressant de savoir c'est est ce que la moyenne est bonne parce que la matière est plus facile, ou les personnes qui utilisent mieux l'IA en STEM sont meilleurs que les autres, allons focus sur les STEM

select prompt_engineering_skill,   avg((post_semester_gpa + pre_semester_gpa) / 2.0) as moyenne_general, avg(traditional_study_hours) as avg_study_hours
from ai_student
where major_category = "STEM"
group by prompt_engineering_skill
order by moyenne_general desc;

#encore une fois ceux qui maitrisent mieux l'IA se retrouvent en premier et sont encore ceux qui travaillent le moins, meme si les intermediate sont derrière les beginner

#regardons du côté des humanités qui ne sont pas expert en IA et qui ne l'utilisent pas beaucoup
select prompt_engineering_skill,   avg((post_semester_gpa + pre_semester_gpa) / 2.0) as moyenne_general, avg(traditional_study_hours) as avg_study_hours
from ai_student
where major_category = "Humanities"
group by prompt_engineering_skill
order by moyenne_general desc;

#même en humanités on retrouve la même idée avec advanced beginner et intermediate dans cette ordre

#on veut voir si le niveau est corrélé au nombre de tool utilisés 

select prompt_engineering_skill,   avg((post_semester_gpa + pre_semester_gpa) / 2.0) as moyenne_general, avg(tool_diversity) as avg_tool_diversity
from ai_student

group by prompt_engineering_skill
order by moyenne_general desc;

#Plus tu t'y connais en IA plus tu utilises différents tools (assez logique)

#Nous avons des chiffres sur la santé mentale essayons d'en savoir plus

select major_category, avg(weekly_genai_hours) as avg_genai_hours, sum(case when burnout_risk_level = 'low' then 1 else 0 end) as nbr_low,
sum(case when burnout_risk_level = 'medium' then 1 else 0 end) as nbr_medium,
sum(case when burnout_risk_level = 'high' then 1 else 0 end) as nbr_high,
count(*) AS nbr_students
from (
select * 
from ai_student
where weekly_genai_hours >=20 
order by weekly_genai_hours desc) as top_users_ia
group by major_category
order by avg_genai_hours desc;

# sur les 2399 personnes qui utilisent plus de 20h l'ia en STEM 1826 ont un fort risque de burnout et le ratio est élevé pour toutes les catégories
select major_category, avg(weekly_genai_hours) as avg_genai_hours, sum(case when burnout_risk_level = 'low' then 1 else 0 end) as nbr_low,
sum(case when burnout_risk_level = 'medium' then 1 else 0 end) as nbr_medium,
sum(case when burnout_risk_level = 'high' then 1 else 0 end) as nbr_high,
count(*) AS nbr_students
from (
select * 
from ai_student
where weekly_genai_hours <=20 
order by weekly_genai_hours desc) as bottom_users_ia
group by major_category
order by avg_genai_hours desc;

#là c'est le nombre de low qui est beaucoup plus élevé dans les personnes qui utilisent moins l'ia


#et pour l'anxiété :

select major_category,  avg(anxiety_level_during_exams) as avg_anxiety
from (
select * 
from ai_student
where weekly_genai_hours <=20 
order by weekly_genai_hours desc) as top_users_ia
group by major_category
order by avg_anxiety desc;

select major_category,  avg(anxiety_level_during_exams) as avg_anxiety
from (
select * 
from ai_student
where weekly_genai_hours >=20 
order by weekly_genai_hours desc) as bottom_users_ia
group by major_category
order by avg_anxiety desc;

#très anxieux pendant les exams si tu utilisent plus de 20h par semaines l'ia (en moyenne 1 point de plus) que si tu utilises moins de 20h


#petite analyse de la progression
select
prompt_engineering_skill,
avg(post_semester_gpa - pre_semester_gpa) as progression
from ai_student
group by prompt_engineering_skill
order by progression desc;

#Il sembre que plus tu es bon en IA plus tu progresses