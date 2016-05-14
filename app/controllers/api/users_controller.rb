module Api
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    # GET /users
    # GET /users.json

    def index()
      ary = params[:params].split("_")
      command = ary[0]
      params = ary[1,ary.length]
      logger.info(ary)
      if command == "ATK" then
        result = attack(params)
      elsif command == "ATKD" then
        result = attacked(params)
      elsif command == "BLK" then
        result = block(params)
      elsif command == "NBLK" then
        result = notblock(params)
      elsif command == "INQR" then
        result = inquire_result(params)
      elsif command == "MKUR" then
        result = make_user(params)
      elsif command == "RANK" then
        result = ranking(params)
      elsif command == "GPNT" then
        result = get_point(params)
      elsif command == "LS" then
        result = check_UUID(params)
      end
      

      logger.info("result")
      logger.info(result)
      render json: result
    end

    def attack(params)
      logger.info(params)
      @A_name = params[0]
      @D_UUID = params[1]

      @A = User.find_by(name: @A_name)
      @D = User.find_by(UUID: @D_UUID) 

      result = attack_create(@A.id, @D.id, 0)

      return result
    end

    def attack_create(a_id,d_id,result)
      #attackがされてないかどうか確かめる処理を書く
      if Attack.exists?(attacker_id: a_id) || Attack.exists?(attacker_id: d_id) || Attack.exists?(defender_id: a_id) || Attack.exists?(defender_id: d_id) then
        return 0
      end

      #攻撃されていないなら
      @attack = Attack.new(:attacker_id=>a_id,:defender_id=>d_id,:result=>result)

      if @attack.save
        return 1
      else
        return 0
      end
    end

    def attacked(params)
      @d_name = params[0]
      logger.info(@d_name)
      @D = User.find_by(name: @d_name)
      if Attack.exists?(defender_id: @D.id) then
        return 1
      else
        return 0
      end
    end

    def block(params)
      @d_name = params[0]
      @D = User.find_by(name: @d_name)
      change_result(@D.id, 1)
    end

    def notblock(params)
      @d_name = params[0]
      @D = User.find_by(name: @d_name)
      change_result(@D.id, 2)
    end

    def change_result(d_id, result)
      @attack = Attack.find_by(defender_id: d_id)
      @attack.result = result
      if @attack.save then
        return 1
      else
        return -1
      end

    end

    def inquire_result(params)
      @a_name = params[0]
      @A = User.find_by(name: @a_name)
      @attack = Attack.find_by(attacker_id: @A.id)

      if !@attack then
        return -1
      end

      result = @attack.result
      if @attack.result == 0 then
        return 0
      else
        return result
      end
    end

    def attack_destroy(user_id)
      @attacker = Attack.find_by(attacker_id: user_id)
      @defender = Attack.find_by(defender_id: user_id)

      if @attacker then
        @attacker.attacker_id = 0
        @attacker.save
        result = @attacker.result + 2

        if @attacker.attacker_id == 0 && @attacker.defender_id == 0 then
          @attacker.destroy
        end

      elsif @defender then
        @defender.defender_id = 0
        @defender.save
        result = @defender.result

        if @defender.attacker_id == 0 && @defender.defender_id == 0 then
          @defender.destroy
        end

      else
        result = -1
      end

      return result
    end

    def make_user(params)
      name = params[0]
      mail = params[1]
      pass = params[2]
      @UUID = params[3]
      point = 0

      if User.exists?(name: name)
        return 0
      end

      @user = User.new(:name=>name,:mail=>mail,:pass=>pass,:UUID=>@UUID,:point=>point)

      if @user.save
        return 1
      else
        return -1
      end
    end

    def ranking(params)
      u_name = params[0]
      @users = User.order("point DESC")

      lists = []
      flag = 0
      cnt = 1
      for u in @users do
        l = user_shape(u)
        l.insert(0,cnt)
        if l.include?(u_name) then
          flag = 1
        end

        if cnt >= 5 && flag == 1 then
          lists.push(l)
          break
        elsif cnt <= 5 then
          lists.push(l)
        end

        cnt += 1
      end

      return lists
    end

    def get_point(params)
      u_name = params[0]
      @users = User.order("point DESC")

      cnt = 1
      for u in @users do
        if u.name == u_name then
          result = attack_destroy(u.id)
          update_point(u,result)
          return [cnt,u.name,u.point]
        end
        cnt += 1
      end

      return -1
    end

    def user_shape(user)
      name = user.name 
      point = user.point
      return [name,point]
    end

    def check_UUID(params)
      @UUID = params[0]
      @user = User.find_by(UUID: @UUID)

      if !@user then
        return 0
      else
        u_name = @user.name
        cnt = 1
        @users = User.order("point DESC")
        for u in @users do
          if u.name == u_name then
            return [cnt,u.name,u.point]
          end
          cnt += 1
        end
      end
    end

    def update_point(user,result)
      if result == 1 then
        user.point += 5
      elsif result == 2 then
        user.point -= 5
      elsif result == 3 then
        user.point -= 15
      elsif result == 4 then
        user.point += 10
      end
      user.save
    end


    # GET /users/1
    # GET /users/1.json
    def show
    end

    # GET /users/new
    def new
      @user = User.new
    end

    # GET /users/1/edit
    def edit
    end

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, notice: 'User was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /users/1
    # PATCH/PUT /users/1.json
    def update
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.json
    def destroy
      @user.destroy
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.require(:user).permit(:name, :mail, :pass, :UUID, :point)
      end
  end
end